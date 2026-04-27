import json
import os
import boto3
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

ec2_client = boto3.client('ec2')
rds_client = boto3.client('rds')
s3_client = boto3.client('s3')

# environment variables
EC2_INSTANCE_ID = os.environ['EC2_INSTANCE_ID']
RDS_INSTANCE_ID = os.environ['RDS_INSTANCE_ID']
S3_BUCKET_NAME = os.environ['S3_BUCKET_NAME']


def lambda_handler(event, context) :
    """CloudWatch Alarm State Change"""
    detail = event.get('detail',{})
    alarm_name = detail.get('alarmName','')
    state = detail.get('state',{}).get('value','')
    
    if state != 'ALARM' :
        return {
            'message' : f'Ignored state: {state}'
        }
    
    logger.info(f"Processing alarm: {alarm_name}")
    
    try :
        
        # EC2 idle (CPU < 5%) 
        if 'ec2-idle' in alarm_name :
            return handle_ec2_idle()
        
        # EC2 overload (CPU >= 60) - if it's used in future 
        elif 'ec2-cpu-overload' in alarm_name : 
            return {
                'message' : 'EC2 overload alarm - action not configured yet (because of Auto Scaling)'    
            }
        
        # RDS idle (CPU < 5%) 
        elif 'rds-idle' in alarm_name :
            return handle_rds_idle()
            
    except Exception as e:
        logger.error(f"Action failed for {alarm_name}: {str(e)}")
        raise

def handle_ec2_idle():
    pass

def handle_rds_idle():
    pass

def handle_rds_zero_connections():
    pass

def handle_s3_usused():
    pass
