# 1. ASG - Idle Alarm (Group Average CPU < 5% for 15 mins)
resource "aws_cloudwatch_metric_alarm" "asg_idle" {
  alarm_name = "asg-idle-cpu-below-5-percent"
  comparison_operator = "LessThanThreshold"
  evaluation_periods = 1
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = 900 # 15 mins
  statistic = "Average"
  threshold = 5
  alarm_description = "Alarm if ASG average CPU < 5% for 15 minutes"
  actions_enabled = true
  alarm_actions = [ var.sns_topic_arn ]
  ok_actions = [ var.sns_topic_arn ]

  dimensions = {
    AutoScalingGroupName = var.asg_name
  }

  treat_missing_data = "notBreaching" # if instance stops then stop the alarm
}

# 2. ASG - Overload Alarm (Group Average CPU >= 60% for 10 minutes)
resource "aws_cloudwatch_metric_alarm" "asg_overload" {
  alarm_name = "asg-cpu-overload-above-60-percent"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = 2 # 2 periods - 10 mins if period 300
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = 300 # 5 minutes
  statistic = "Average"
  threshold = 60
  alarm_description = "Alarm if ASG average CPU >= 60% for 10 minutes"
  actions_enabled = true
  alarm_actions = [var.sns_topic_arn]
  ok_actions = [ var.sns_topic_arn ]

  dimensions = {
    AutoScalingGroupName = var.asg_name
  }
}

# 3. RDS - Capacity Allocated But Not Used (CPU < 5% for 10 minutes)
resource "aws_cloudwatch_metric_alarm" "rds_idle" {
  alarm_name = "rds-idle-cpu-below-5-percent"
  comparison_operator = "LessThanThreshold"
  evaluation_periods = 3 # 20 minutes 
  datapoints_to_alarm = 2
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

# # 4. RDS zero database connections
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

# 5. S3 - Old Logs & Unused Backups (no request for 1 hours)

resource "aws_cloudwatch_metric_alarm" "s3_ghost_bucket" {
  alarm_name = "s3-unused-bucket-trigger"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods = 1
  metric_name = "AllRequests"
  namespace = "AWS/S3"
  period = 86400 # 24 hours (daily check)
  statistic = "Sum"
  threshold = 0

  dimensions = {
    BucketName = var.s3_bucket_name
    FilterId = "EntireBucket"
  }

  alarm_description = "Trigger if there is zero activity in the S3 bucket for 24 hours."
  actions_enabled = true
  alarm_actions = [var.sns_topic_arn]
  ok_actions = [ var.sns_topic_arn ]
}

# Combine S3 Bucket Request (GET,PUT,POST,DELETE)
# resource "aws_cloudwatch_metric_alarm" "s3_no_requests" {
#   alarm_name = "s3-no-requests"
#   comparison_operator = "LessThanOrEqualToThreshold"
#   threshold = 0
#   evaluation_periods = 1 # 1 hours

#   alarm_description = "Alarm when no S3 activity (GET, PUT, POST, DELETE)"

#   actions_enabled = true
#   alarm_actions = [var.sns_topic_arn]
#   ok_actions = [var.sns_topic_arn]

#   metric_query {
#     id = "e1"
#     expression = "m1 + m2 + m3 + m4"
#     label = "TotalRequests"
#     return_data = true
#   }
  
#   # S3 GET Requests
#   metric_query {
#     id = "m1"
#     metric {
#       metric_name = "GetRequests"
#       namespace = "AWS/S3"
#       period = 3600
#       stat = "Sum"
#       dimensions = {
#         BucketName = var.s3_bucket_name
#         FilterId = "EntireBucket"
#         StorageType = "AllStorageType"
#       }
#     }
#   }
  
#   # S3 PUT Requests
#   metric_query {
#     id = "m2"
#     metric {
#       metric_name = "PutRequests"
#       namespace = "AWS/S3"
#       period = 3600
#       stat = "Sum"
#       dimensions = {
#         BucketName = var.s3_bucket_name
#         FilterId = "EntireBucket"
#         StorageType = "AllStorageType"
#       }
#     }
#   }
  
#   # S3 POST Requests
#   metric_query {
#     id = "m3"
#     metric {
#       metric_name = "PostRequests"
#       namespace = "AWS/S3"
#       period = 3600
#       stat = "Sum"
#       dimensions = {
#         BucketName = var.s3_bucket_name
#         FilterId = "EntireBucket"
#         StorageType = "AllStorageType"
#       }
#     }
#   }

#   # S3 DELETE Requests
#   metric_query {
#     id = "m4"
#     metric {
#       metric_name = "DeleteRequests"
#       namespace = "AWS/S3"
#       period = 3600
#       stat = "Sum"
#       dimensions = {
#         BucketName = var.s3_bucket_name
#         FilterId = "EntireBucket"
#         StorageType = "AllStorageType"
#       }
#     }
#   }

#   treat_missing_data = "breaching"
# }