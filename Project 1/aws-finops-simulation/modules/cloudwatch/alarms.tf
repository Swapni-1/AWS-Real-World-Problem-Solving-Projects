# 1. EC2 - Idleness Alarm (CPU < 5% for 1 hour)
resource "aws_cloudwatch_metric_alarm" "ec2_idle" {
  alarm_name = "ec2-idle-cpu-below-5-percent"
  comparison_operator = "LessThanThreshold"
  evaluation_periods = 1
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = 900 # 15 mins
  statistic = "Average"
  threshold = 5
  alarm_description = "Alarm if EC2 instance average CPU < 5% for 1 hour (idle)"
  actions_enabled = true
  alarm_actions = [ var.sns_topic_arn ]
  ok_actions = [ var.sns_topic_arn ]

  dimensions = {
    InstanceId = var.ec2_instances_id
  }

  treat_missing_data = "notBreaching" # if instance stops then stop the alarm
}

# 2. EC2 - CPU Overloading Alarm (CPU > 75% for 10 minutes)
resource "aws_cloudwatch_metric_alarm" "ec2_overload" {
  alarm_name = "ec2-cpu-overload-above-75-percent"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = 2 # 2 periods - 10 mins if period 300
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = 300 # 5 minutes
  statistic = "Average"
  threshold = 75
  alarm_description = "Alarm if EC2 CPU > 75% for 10 minutes (overloaded)"
  actions_enabled = true
  alarm_actions = [var.sns_topic_arn]
  ok_actions = [ var.sns_topic_arn ]

  dimensions = {
    InstanceId = var.ec2_instances_id
  }
}

# 3. RDS - Capacity Allocated But Not Used (CPU < 5% for 1 hours)
resource "aws_cloudwatch_metric_alarm" "rds_idle" {
  alarm_name = "rds-idle-cpu-below-5-percent"
  comparison_operator = "LessThanThreshold"
  evaluation_periods = 1
  metric_name = "CPUUtilization"
  namespace = "AWS/RDS"
  period = 600
  statistic = "Average"
  threshold = 5
  alarm_description = "RDS instance CPU < 5% 10 mins (allocated but not used)."
  actions_enabled = true
  alarm_actions = [ var.sns_topic_arn ]
  ok_actions = [ var.sns_topic_arn ]

  dimensions = {
    DBInstanceIdentifier = var.rds_instance_identifier
  }

  treat_missing_data = "notBreaching"
}

# 4. RDS zero database connections
resource "aws_cloudwatch_metric_alarm" "rds_zero_connections" {
  alarm_name = "rds-zero-database-connections"
  comparison_operator = "LessThanThreshold"
  evaluation_periods = 1 # 1 hours
  metric_name = "DatabaseConnections"
  namespace = "AWS/RDS"
  period = 600 
  statistic = "Average"
  threshold = 1
  alarm_description = "RDS has zero active connections (unused)."
  actions_enabled = true
  alarm_actions = [ var.sns_topic_arn ]
  ok_actions = [ var.sns_topic_arn ]
  
  dimensions = {
    DBInstanceIdentifier = var.rds_instance_identifier
  }

  treat_missing_data = "notBreaching"
}

# 5. S3 - Old Logs & Unused Backups (no request for 7 days)

# First of all requrest enable request matrics
resource "aws_s3_bucket_metric" "bucket_requests" {
  bucket = var.s3_bucket_name
  name = "EntireBucket"
}

# Now Alarm: Within 1 hour total AllRequests = 0 -> Repeat for 1 hours means breach
resource "aws_cloudwatch_metric_alarm" "s3_unused" {
  alarm_name = "s3-bucket-no-requests-10-min"
  comparison_operator = "LessThanOrEqualToThreshold"
  threshold = 0
  evaluation_periods = 1 # 1 hour
  period = 600 # 
  metric_name = "AllRequests"
  namespace = "AWS/S3"
  statistic = "Sum"
  alarm_description = "Alarm when S3 bucket has zero requests for 24 consecutive hours (old logs/unused backups)."
  actions_enabled = true
  alarm_actions = [ var.sns_topic_arn ]
  ok_actions = [ var.sns_topic_arn ]

  dimensions = {
    BucketName = var.s3_bucket_name
    StorageType = "AllStorageTypes" # important for S3 dimensions
  }

  # Assume breach if requests will not come then metric data point will absent
  treat_missing_data = "breaching"

  depends_on = [ aws_s3_bucket_metric.bucket_requests ]
}