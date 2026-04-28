resource "aws_cloudwatch_dashboard" "central_monitoring" {
  dashboard_name = var.dashboard_name

  dashboard_body = jsonencode({
    widgets = [
      # ---------- Row 1: EC2 ----------
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", "InstanceId", var.ec2_instances_id, { stat = "Average", period = 300, label = "EC2 CPU %" }]
          ]
          view    = "timeSeries"
          region  = var.aws_region
          title   = "EC2 CPU Utilization"
          yAxis   = { left = { min = 0, max = 100 } }
        }
      },
      # EC2 Idle Alarm (Single Value)
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 6
        height = 6
        properties = {
          metrics = [
            # AlarmState ke liye sirf 2 parameters aur config object kaafi hai
            ["AWS/CloudWatch", "AlarmState", "AlarmName", aws_cloudwatch_metric_alarm.ec2_idle.alarm_name]
          ]
          view    = "singleValue"
          region  = var.aws_region
          title   = "EC2 Idle Alarm State"
        }
      },
      # EC2 Overload Alarm
      {
        type   = "metric"
        x      = 18
        y      = 0
        width  = 6
        height = 6
        properties = {
          metrics = [
            ["AWS/CloudWatch", "AlarmState", "AlarmName", aws_cloudwatch_metric_alarm.ec2_overload.alarm_name]
          ]
          view    = "singleValue"
          region  = var.aws_region
          title   = "EC2 Overload Alarm State"
        }
      },

      # ---------- Row 2: RDS ----------
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", var.rds_instance_identifier, { stat = "Average", period = 300, label = "RDS CPU %" }]
          ]
          view    = "timeSeries"
          region  = var.aws_region
          title   = "RDS CPU Utilization"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", var.rds_instance_identifier, { stat = "Average", period = 300, label = "Connections" }]
          ]
          view    = "timeSeries"
          region  = var.aws_region
          title   = "RDS Database Connections"
        }
      },
      # # RDS Idle Alarm
      # {
      #   type   = "metric"
      #   x      = 12
      #   y      = 6
      #   width  = 6
      #   height = 6
      #   properties = {
      #     metrics = [
      #        ["AWS/CloudWatch", "AlarmState", "AlarmName", aws_cloudwatch_metric_alarm.rds_idle.alarm_name]
      #     ]
      #     view    = "singleValue"
      #     region  = var.aws_region
      #     title   = "RDS Idle Alarm State"
      #   }
      # },
      # # RDS Zero Connections Alarm
      # {
      #   type   = "metric"
      #   x      = 18
      #   y      = 6
      #   width  = 6
      #   height = 6
      #   properties = {
      #     metrics = [
      #       ["AWS/CloudWatch", "AlarmState", "AlarmName", aws_cloudwatch_metric_alarm.rds_zero_connections.alarm_name]
      #     ]
      #     view    = "singleValue"
      #     region  = var.aws_region
      #     title   = "RDS Zero Connections Alarm"
      #   }
      # },

      # ---------- Row 3: S3 ----------
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6
        properties = {
          metrics = [
            # S3 metrics dimensions (BucketName, StorageType) array mein sahi se daalein
            ["AWS/S3", "GetRequests", "BucketName", var.s3_bucket_name, "FilterId", "EntireBucket", { stat = "Sum", period = 300 }]
          ]
          view    = "timeSeries"
          region  = var.aws_region
          title   = "S3 Bucket Daily GET Requests"
        }
      },
       {
        type   = "metric"
        x      = 0
        y      = 18
        width  = 12
        height = 6
        properties = {
          metrics = [
            # S3 metrics dimensions (BucketName, StorageType) array mein sahi se daalein
            ["AWS/S3", "PutRequests", "BucketName", var.s3_bucket_name, "FilterId", "EntireBucket", { stat = "Sum", period = 300 }]
          ]
          view    = "timeSeries"
          region  = var.aws_region
          title   = "S3 Bucket Daily PUT Requests"
        }
      },
       {
        type   = "metric"
        x      = 12
        y      = 18
        width  = 12
        height = 6
        properties = {
          metrics = [
            # S3 metrics dimensions (BucketName, StorageType) array mein sahi se daalein
            ["AWS/S3", "PostRequests", "BucketName", var.s3_bucket_name, "FilterId", "EntireBucket", { stat = "Sum", period = 300 }]
          ]
          view    = "timeSeries"
          region  = var.aws_region
          title   = "S3 Bucket Daily POST Requests"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 12
        width  = 12
        height = 6
        properties = {
          metrics = [
            # S3 metrics dimensions (BucketName, StorageType) array mein sahi se daalein
            ["AWS/S3", "DeleteRequests", "BucketName", var.s3_bucket_name, "FilterId", "EntireBucket", { stat = "Sum", period = 300 }]
          ]
          view    = "timeSeries"
          region  = var.aws_region
          title   = "S3 Bucket Daily DELETE Requests"
        }
      },
      # S3 Unused Alarms (GET,PUT,POST,DELETE)
      {
        type   = "metric"
        x      = 0
        y      = 24
        width  = 6
        height = 6
        properties = {
          metrics = [
            ["AWS/CloudWatch", "AlarmState", "AlarmName", aws_cloudwatch_metric_alarm.s3_get_requests.alarm_name]
          ]
          view    = "singleValue"
          region  = var.aws_region
          title   = "S3 GET Requests Bucket Alarm State"
        }
      },
      {
        type   = "metric"
        x      = 6
        y      = 24
        width  = 6
        height = 6
        properties = {
          metrics = [
            ["AWS/CloudWatch", "AlarmState", "AlarmName", aws_cloudwatch_metric_alarm.s3_put_requests.alarm_name]
          ]
          view    = "singleValue"
          region  = var.aws_region
          title   = "S3 PUT Requests Bucket Alarm State"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 24
        width  = 6
        height = 6
        properties = {
          metrics = [
            ["AWS/CloudWatch", "AlarmState", "AlarmName", aws_cloudwatch_metric_alarm.s3_post_requests.alarm_name]
          ]
          view    = "singleValue"
          region  = var.aws_region
          title   = "S3 POST Requests Bucket Alarm State"
        }
      },
      {
        type   = "metric"
        x      = 18
        y      = 24
        width  = 6
        height = 6
        properties = {
          metrics = [
            ["AWS/CloudWatch", "AlarmState", "AlarmName", aws_cloudwatch_metric_alarm.s3_delete_requests.alarm_name]
          ]
          view    = "singleValue"
          region  = var.aws_region
          title   = "S3 DELETE Requests Bucket Alarm State"
        }
      }
    ]
  })
}