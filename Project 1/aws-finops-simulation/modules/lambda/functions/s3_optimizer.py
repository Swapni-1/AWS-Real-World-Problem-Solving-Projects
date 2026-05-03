import boto3
import os
from datetime import datetime, timedelta, timezone

# AWS Clients
s3 = boto3.client('s3')
cw = boto3.client('cloudwatch')

def lambda_handler(event, context) :
    # Environment Variables
    bucket_name = os.environ['S3_BUCKET']
    
    # 1. Check previous last 3 days total requests (AllRequests)
    metric = cw.get_metric_data(
        MetricDataQueries=[
            {
                'Id': 's3_requests',
                'MetricStat': {
                    'Metric': {
                        'Namespace': 'AWS/S3',
                        'MetricName': 'AllRequests',
                        'Dimensions': [
                            {
                                'Name': 'BucketName',
                                'Value': bucket_name
                            },
                            {
                                'Name': 'FilterId',
                                'Value': 'EntireBucket'
                            }
                        ]
                    },
                    'Period': 86400 * 3, # 3 days period (in seconds)
                    'Stat': 'Sum'
                },
            }
        ],
        StartTime = datetime.now(timezone.utc) - timedelta(days=3),
        EndTime = datetime.now(timezone.utc),
    )
    
    total_requests = 0
    if metric['MetricDataResults'][0]['Values']:
        total_requests = sum(metric['MetricDataResults'][0]['Values'])
    
    print(f"Bucket: {bucket_name}, Total Requests in last 3 days: {total_requests}")
    
    # --- HYBRID LOGIC START ---
    
    # Scenario 1: Zero activity for 3 days -> Delete all objects (Cleanup)
    if total_requests == 0 :
        print(f"No activity detected for 3 days. Cleaning up all objects in {bucket_name}...")
        
        paginator = s3.get_paginator('list_objects_v2')
        for page in paginator.paginate(Bucket=bucket_name):
            if 'Contents' in page:
                delete_keys = [{'Key': obj['Key']} for obj in page['Contents']]
                s3.delete_objects(Bucket=bucket_name, Delete={'Objects': delete_keys})
        print("Cleanup completed.")
    
    # Scenario 2: Active bucket -> Apply Multi-Tier Lifecycle Policy
    else :
        print(f"Activity detected. Applying Multi-Tier Lifecycle Policy to {bucket_name}...")
        
        lifecycle_policy = {
            'Rules' : [
                {
                    'ID': 'MultiTierOptimizationRule',
                    'Status': 'Enabled',
                    'Filter': {
                        'Prefix': ''  # Apply to all objects
                    },
                    'Transitions': [
                        {
                            # 30 days -> Glacier Instant Retrieval
                            'Days': 30,
                            'StorageClass': 'GLACIER_IR'  
                        },
                        {
                            # 90 days -> Glacier Flexible Retrieval (Pehle 'GLACIER' kehte the)
                            'Days': 90,
                            'StorageClass': 'GLACIER'
                        },
                        {
                            # 180 days -> Glacier Deep Archive
                            'Days': 180,
                            'StorageClass': 'DEEP_ARCHIVE'
                        }
                    ],
                    'Expiration': {
                        # 365 days -> Permanent Delete
                        'Days': 365
                    }
                }
            ]
        }
        
        s3.put_bucket_lifecycle_configuration(
            Bucket=bucket_name,
            LifecycleConfiguration=lifecycle_policy
        )
        
        print("Multi-tier Lifecycle policy updated successfully.")
        
        return {
            'statusCode': 200,
            'body': f"Optimization check finished for {bucket_name}"
        }