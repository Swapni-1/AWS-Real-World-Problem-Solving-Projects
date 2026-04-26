resource "aws_cloudwatch_dashboard" "central_monitoring" {
  dashboard_name = var.dashboard_name

  dashboard_body = jsonencode({
    widgets = [
      # ----- EC2 Cpu Utilization ------
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            # Line 1: Average CPU
            ["AWS/EC2", "CPUUtilization", "InstanceId", var.ec2_instances_id, { stat = "Average" }],
            # Line 2: p95 CPU (Repeat marker ki jagah full path use karein)
            ["AWS/EC2", "CPUUtilization", "InstanceId", var.ec2_instances_id, { stat = "p95", period = 300 }]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "EC2 CPU Utilization (avg + p95)"
          yAxis = {
            left = { min = 0, max = 100 }
          }
        }
      },

      # ----- EC2 Network In/Out
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/EC2", "NetworkIn", "InstanceId", var.ec2_instances_id],
            [".", "NetworkOut", ".", "."] # Dot (.) means repeat from previous
          ]
          period = 300
          stat   = "Sum"
          region = var.aws_region
          title  = "EC2 Network In/Out (bytes)"
        }
      },

      # ----- RDS CPU Utilization ----------
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = { # Sab kuch iske andar hona chahiye
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", var.rds_instance_id]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "RDS CPU Utilization"
        }
      },

      # ------ RDS Storage + Database Connections -------
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/RDS", "FreeStorageSpace", "DBInstanceIdentifier", var.rds_instance_id],
            [".", "DatabaseConnections", ".", "."]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "RDS Free Storage and Connection"
        }
      },

      # ------ S3 Bucket Size & Object count (daily) ------------
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/S3", "BucketSizeBytes", "StorageType", "StandardStorage", "BucketName", var.s3_bucket_name],
            ["AWS/S3", "NumberOfObjects", "StorageType", "AllStorageTypes", "BucketName", var.s3_bucket_name]
          ]
          period = 86400
          stat   = "Average"
          region = var.aws_region # S3 metrics usually global but region required in widget
          title  = "S3 Bucket Size and Object Count (daily)"
        }
      }
    ]
  })
}