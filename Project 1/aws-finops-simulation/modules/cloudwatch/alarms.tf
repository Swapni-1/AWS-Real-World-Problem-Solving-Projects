# 1. EC2 - Idleness Alarm (CPU < 5% for 15 minutes)
resource "aws_cloudwatch_metric_alarm" "ec2_idle" {
  alarm_name = "ec2-idle-cpu-below-5-percent"
  comparison_operator = "LessThanThreshold"
  evaluation_periods = 1
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = 900 # 15 mins
  statistic = "Average"
  threshold = 5
  alarm_description = "Alarm if EC2 instance average CPU < 5% for 15 minutes (idle)"
  actions_enabled = true
  alarm_actions = [ var.sns_topic_arn ]
  ok_actions = [ var.sns_topic_arn ]

  dimensions = {
    InstanceId = var.ec2_instances_id
  }

  treat_missing_data = "notBreaching" # if instance stops then stop the alarm
}

# 2. EC2 - CPU Overloading Alarm (CPU >= 60% for 10 minutes)
resource "aws_cloudwatch_metric_alarm" "ec2_overload" {
  alarm_name = "ec2-cpu-overload-above-and-equal-60-percent"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = 2 # 2 periods - 10 mins if period 300
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = 300 # 5 minutes
  statistic = "Average"
  threshold = 60
  alarm_description = "Alarm if EC2 CPU > 75% for 10 minutes (overloaded)"
  actions_enabled = true
  alarm_actions = [var.sns_topic_arn]
  ok_actions = [ var.sns_topic_arn ]

  dimensions = {
    InstanceId = var.ec2_instances_id
  }
}

# 3. RDS - Capacity Allocated But Not Used (CPU < 5% for 10 minutes)
# resource "aws_cloudwatch_metric_alarm" "rds_idle" {
#   alarm_name = "rds-idle-cpu-below-5-percent"
#   comparison_operator = "LessThanThreshold"
#   evaluation_periods = 1
#   metric_name = "CPUUtilization"
#   namespace = "AWS/RDS"
#   period = 600
#   statistic = "Average"
#   threshold = 5
#   alarm_description = "RDS instance CPU < 5% 10 mins (allocated but not used)."
#   actions_enabled = true
#   alarm_actions = [ var.sns_topic_arn ]
#   ok_actions = [ var.sns_topic_arn ]

#   dimensions = {
#     DBInstanceIdentifier = var.rds_instance_identifier
#   }

#   treat_missing_data = "notBreaching"
# }

# 4. RDS zero database connections
# resource "aws_cloudwatch_metric_alarm" "rds_zero_connections" {
#   alarm_name = "rds-zero-database-connections"
#   comparison_operator = "LessThanThreshold"
#   evaluation_periods = 1 # 1 hours 
#   metric_name = "DatabaseConnections"
#   namespace = "AWS/RDS"
#   period = 3600 # 60 minutes
#   statistic = "Average"
#   threshold = 1
#   alarm_description = "RDS has zero active connections (unused)."
#   actions_enabled = true
#   alarm_actions = [ var.sns_topic_arn ]
#   ok_actions = [ var.sns_topic_arn ]
  
#   dimensions = {
#     DBInstanceIdentifier = var.rds_instance_identifier
#   }

#   treat_missing_data = "notBreaching"
# }

# 5. S3 - Old Logs & Unused Backups (no request for 24 hours)

# S3 - GET Requests Alarm
resource "aws_cloudwatch_metric_alarm" "s3_get_requests" {
  alarm_name = "${var.s3_bucket_name}-no-get-requests"
  comparison_operator = "LessThanThreshold"
  evaluation_periods = 1 # 1 hour
  metric_name = "GetRequests"
  namespace = "AWS/S3"
  period = 3600 # 60 minutes
  statistic = "Sum"
  threshold = 1
  alarm_description = "Alarm when S3 GET Requests exceeds threshold (60-mins sum)"

  actions_enabled = var.sns_topic_arn != "" ? true : false
  alarm_actions = var.sns_topic_arn != "" ? [ var.sns_topic_arn ] : []
  ok_actions = var.sns_topic_arn != "" ? [ var.sns_topic_arn ] : []

  dimensions = {
    BucketName = var.s3_bucket_name
    FilterId = "EntireBucket"
    StorageType = "AllStorageType"
  }

  treat_missing_data = "breaching"
}

# S3 PUT Requests Alarm
resource "aws_cloudwatch_metric_alarm" "s3_put_requests" {
  alarm_name = "${var.s3_bucket_name}-no-put-requests"
  comparison_operator = "LessThanThreshold"
  evaluation_periods = 1 # 1 hour
  metric_name = "PutRequests"
  namespace = "AWS/S3"
  period = 3600 # 60 minutes
  statistic = "Sum"
  threshold = 1
  alarm_description = "Alarm when S3 PUT Requests exceeds threshold (60-mins sum)"

  actions_enabled = var.sns_topic_arn != "" ? true : false
  alarm_actions = var.sns_topic_arn != "" ? [ var.sns_topic_arn ] : []
  ok_actions = var.sns_topic_arn != "" ? [ var.sns_topic_arn ] : []

  dimensions = {
    BucketName = var.s3_bucket_name
    FilterId = "EntireBucket"
    StorageType = "AllStorageType"
  }

  treat_missing_data = "breaching"
}

# S3 POST Requests Alarm
resource "aws_cloudwatch_metric_alarm" "s3_post_requests" {
  alarm_name = "${var.s3_bucket_name}-no-post-requests"
  comparison_operator = "LessThanThreshold"
  evaluation_periods = 1 # 1 hour
  metric_name = "PostRequests"
  namespace = "AWS/S3"
  period = 3600 # 60 minutes
  statistic = "Sum"
  threshold = 1
  alarm_description = "Alarm when S3 POST Requests exceeds threshold (60-mins sum)"

  actions_enabled = var.sns_topic_arn != "" ? true : false
  alarm_actions = var.sns_topic_arn != "" ? [ var.sns_topic_arn ] : []
  ok_actions = var.sns_topic_arn != "" ? [ var.sns_topic_arn ] : []

  dimensions = {
    BucketName = var.s3_bucket_name
    FilterId = "EntireBucket"
    StorageType = "AllStorageType"
  }

  treat_missing_data = "breaching"
}


# S3 DELETE Requests Alarm
resource "aws_cloudwatch_metric_alarm" "s3_delete_requests" {
  alarm_name = "${var.s3_bucket_name}-no-delete-requests"
  comparison_operator = "LessThanThreshold"
  evaluation_periods = 1 # 1 hour
  metric_name = "DeleteRequests"
  namespace = "AWS/S3"
  period = 3600 # 60 minutes
  statistic = "Sum"
  threshold = 1
  alarm_description = "Alarm when S3 DELETE Requests exceeds threshold (60-mins sum)"

  actions_enabled = var.sns_topic_arn != "" ? true : false
  alarm_actions = var.sns_topic_arn != "" ? [ var.sns_topic_arn ] : []
  ok_actions = var.sns_topic_arn != "" ? [ var.sns_topic_arn ] : []

  dimensions = {
    BucketName = var.s3_bucket_name
    FilterId = "EntireBucket"
    StorageType = "AllStorageType"
  }

  treat_missing_data = "breaching"
}