resource "aws_cloudwatch_dashboard" "finops-dashboard" {
  dashboard_name = "FinOps-Dashboard"

  dashboard_body = jsonencode({
    title = "FinOps Dashboard - Cost & Waste Detection"
    
    widgets = [
      # ===========
      # RDS SECTION
      # ===========

      # 6. Utilization vs Capacity Gauage (FreeStorageSpace)
      {
        type = "metric"
        properties = {
          title = "RDS Storage Over-Provisioning"
          region = var.aws_region

          metrics = [
            ["AWS/RDS","FreeStorageSpace","DBInstanceIdentifier",var.rds_instance_id,{ stat = "Minimum" }]
          ]
          view = "guage"
          yAxis = { left = { min = 0 } }
          period = 3600
          stat = "Minimum"
        }
        x = 12
        y = 12
        width = 6
        height = 6
      },

      # 7. Active User Tracker - DatabaseConnections (Threshold 1)
      {
        type = "metric"
        properties = {
          title = "Active Database Connections"
          region = var.aws_region
          
          metrics = [
            ["AWS/RDS","DatabaseConnections","DBInstanceIdentifier",var.rds_instance_id, { stat = "Maximum" } ]
          ]
          view = "timeSeries"
          stacked = false
          annotations = {
            horizontal = [{
              label = "Idle threshold (1 conn)"
              value = 1
              fill = "none"
              color = "#d13212"
            }]
          }
          period = 300
          stat = "Maximum"
        }
        x = 0
        y = 18
        width = 12
        height = 6
      },

      # 8. Compute Efficiency - CPUUtilization ( <5% )
      {
        type = "metric"
        properties = {
          title = "RDS Compute Waste (CPU < 5%)"
          region = var.aws_region

          metrics = [
            ["AWS/RDS","CPUUtilization","DBInstanceIdentifier",var.rds_instance_id]
          ]

          view = "timeSeries"
          stacked = false
          annotations = {
            horizontal = [{
              label = "Idle compute threshold"
              value = 5
              fill = "none"
              color = "#d13212"
            }]
          }
          period = 300
          stat = "Average"
        }
        x = 12
        y = 18
        width = 12
        height = 6
      },

      # 9. IOPS Activity - Stacked Area (ReadIOPS + WriteIOPS)
      {
        type = "metric"
        properties = {
          title = "RDS I/O Activity - Background tasks?"
          region = var.aws_region
          metrics = [
            ["AWS/RDS","ReadIOPS","DBInstanceIdentifier",var.rds_instance_id, { stat = "Sum" }],
            ["AWS/RDS", "WriteIOPS","DBInstanceIdentifier",var.rds_instance_id, { stat = "Sum" }]
          ]
          view = "timeSeries"
          stacked = true
          yAxis = { left = { label = "IOPS" } }
          period = 300
        }
        x = 0
        y = 24
        width = 12
        height = 6
      },

      # 10. RDS Financial Summary Text
      {
        type = "text"
        properties = {
          markdown = <<-EOT
            ## 💵 RDS Financial Impact
            - Stopping RDS during **non-business hours (12h/day)** reduces costs by **50%**
            - Automation status : ✅ Stop/Start Lambda active (check alarms).
            - Right-sizing potential: ${"`FreeStorageSpace`"} shows over-provisioning.   
          EOT
        }
        x = 12
        y = 24
        width = 12
        height = 3
      },

      # ==========
      # S3 SECTION
      # ==========

      # 11. Storage Composition - Pie Chart by Storage Class
      {
        type = "metric"
        properties = {
          title = "S3 Storage Class Composition (Lifecycle success)"
          region = var.aws_region

          metrics = [
            { expression = "SEARCH('{AWS/S3,BucketName,StorageClass} BucketSizeBytes','Average', 86400)", label = "ByClass", id = "e1", visible = false },
            { expression = "SERVICE_QUOTA(e1,10)", label = "Standard", id = "std", stat = "Average", period = 86400 },
            { expression = "SERVICE_QUOTA(e1,20)", label = "Glacier/DeepArchive", id = "glacier", stat = "Average", period = 86400 }
          ]

          view = "pie"
          period = 86400
          stat = "Average"
        }
        x = 0
        y = 0
        width = 8
        height = 6
      },

      # 12. Ghost Bucket Detector - AllRequests (30 daily total)
      {
        type = "metric"

        properties = {
          title = "Ghost Bucket? (Requests last 30 days)"
          region = var.aws_region

          metrics = [
            { expression = "SUM(SEARCH('{AWS/S3,BucketName} MetricName=\"AllRequests\"','Sum',86400))", label = "Daily total requests", id = "req", stat = "Sum", period = 86400 }
          ]
          view = "singleValue"
          period = 86400
          stat = "Sum"
          setPeriodToTimeRange = false
        }
        x = 8
        y = 30
        width = 4
        height = 3
      },

      # 13. Object Count Trend
      {
        type = "metric"
        properties = {
          title = "S3 Object Count Trend"
          region = var.aws_region

          metrics = [
            ["AWS/S3","NumberOfObjects","BucketName",var.s3_bucket_name,"StorageClass","AllStorageTypes", { stat = "Average" }]
          ]
          view = "timeSeries"
          stacked = false
          period = 86400
          stat = "Average"
        }
        x = 12
        y = 30
        width = 6
        height = 6
      },

      # 14. Data Retrieval Analysis - Bar Chart (Get vs Put)
      {
        type = "metric"
        properties = {
          title = "GetRequests vs PutRequests (Archieve decision)"
          region = var.aws_region

          metrics = [
            ["AWS/S3", "GetRequests", "BucketName", var.s3_bucket_name, { stat = "Sum", period = 86400, label = "GET" }],
            ["AWS/S3", "PutRequests", "BucketName", var.s3_bucket_name, { stat = "Sum", period = 86400, label = "PUT" }],
          ]

          view = "bar"
          stacked = false
          period = 86400
          stat = "Sum"
        }

        x = 18
        y = 30
        width = 6
        height = 6
      },

      # 15. Cost-Saving Summary Text for S3
      {
        type = "metric"
        properties = {
          markdown = <<-EOT
            ## 🧊 S3 Cost Savings
            - **Standard Storage:** $0.23/GB
            - **Glacier Deep Archive** $0.00099/GB
            - **Savings Example:** Moving 10 GB logs to Glacier saves **-95%** monthly cost.
            - **Expiration policy:** Delete old backups after 90 days. 
          EOT
        }
      } 
    ]
  })
}