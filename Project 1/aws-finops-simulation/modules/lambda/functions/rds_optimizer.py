import boto3
import os
from datetime import datetime, timedelta, timezone

# Initialize AWS clients
rds = boto3.client('rds')
cw = boto3.client('cloudwatch')

def lambda_handler(event, context) : 
    # Environment Variables
    db_instance_id = os.environ['RDS_INSTANCE_ID']
    
    # 1. Check Current Status of RDS 
    response = rds.describe_db_instances(DBInstanceIdentifier=db_instance_id)
    instance = response['DBInstances'][0]
    status = instance['DBInstanceStatus']
    
    print(f"Checking RDS: {db_instance_id}, Current Status: {status}")
    
    # 2. Get CPU Utilization from CloudWatch (Last 1 hour average)
    metric = cw.get_metric_statistics(
        Namespace='AWS/RDS',
        MetricName='CPUUtilization',
        Dimensions=[
            {
                'Name': 'DBInstanceIdentifier',
                'Value': db_instance_id
            },
        ],
        StartTime = datetime.now(timezone.utc) - timedelta(hours=1),
        EndTime = datetime.now(timezone.utc),
        Period=3600,
        Statistics=['Average']
    )
    
    cpu_avg = 0
    if metric['Datapoints']:
        cpu_avg = metric['Datapoints'][0]['Average']
        
    print(f"Average CPU Utilization: {cpu_avg}%")
    
    # --- LOGIC STARTS ---
    
    # Case A : If CPU < 5% and it's state is running, then stop the instance and tag it
    if cpu_avg < 5 and status == 'available':
        print(f"CPU is idle ({cpu_avg}%). Stopping instance...")
        rds.stop_db_instance(DBInstanceIdentifier=db_instance_id)
        
        # Tag rds idle date (for 3-day counter)
        rds.add_tags_to_resource(
            ResourceName=instance['DBInstanceArn'],
            Tags=[
                {
                    'Key': 'IdleSince',
                    'Value': datetime.now(timezone.utc).strftime('%Y-%m-%d')
                },
            ]
        )
    
    # Case B : If instance is stopped , then check completion of 3 idle days
    elif status == 'stopped':
        tags = rds.list_tags_for_resource(ResourceName=instance['DBInstanceArn'])['TagList']
        idle_since_str = next((tag['Value'] for tag in tags if tag['Key'] == 'IdleSince'), None)
        
        if idle_since_str :
            idle_since_date = datetime.strptime(idle_since_str, '%Y-%m-%d')
            days_idle = (datetime.now(timezone.utc) - idle_since_date).days
            
            print(f"Instance has been idle for {days_idle} days.")
            
            # If idle for more than 3 days, delete the instance (with Final Snapshot for safety)
            if days_idle > 3:
                print("3 days limit reached. Terminating RDS instance...")
                snapshot_id = f"final-snapshot-{db_instance_id}-{datetime.now(timezone.utc).strftime('%Y-%m-%d-%H-%M')}"
                rds.delete_db_instance(
                    DBInstanceIdentifier=db_instance_id,
                    SkipFinalSnapshot=False,
                    FinalDBSnapshotIdentifier=snapshot_id
                )
                
            else :
                print("No 'IdleSince' tag found. Skipping termination check.")
        
        else :
            print("Instance is active or in a state where no action is needed.")
        
        return {
            'statusCode': 200,
            'body': f"Check completed for {db_instance_id}"
        }