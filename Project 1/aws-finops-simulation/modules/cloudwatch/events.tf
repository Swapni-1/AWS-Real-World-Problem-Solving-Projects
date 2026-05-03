# # Rule 1 - EC2 Idle (CPU < 5%)
# resource "aws_cloudwatch_event_rule" "ec2_idle_rule" {
#    name = "capture-ec2-idle-alarm" 
#    description = "Trigger-ec2-idle-alarm"
#    event_pattern = jsonencode({
#       source = ["aws.cloudwatch"]
#       detail-type = ["CloudWatch Alarm State Change"]
#       detail = {
#         alarmName = [aws_cloudwatch_metric_alarm.ec2_idle.alarm_name]
#         state = {
#             value = ["ALARM"]
#         }
#       }
#    })
# }

# # Rule 2 - EC2 Start at 9 a.m. daily
# resource "aws_cloudwatch_event_rule" "ec2_start_at_9am" {
#   name = "start-ec2-daily-9am-ist"
#   description = "Start EC2 instance at 9:00 AM IST (3:30 UTC)"
#   schedule_expression = "cron(30 3 * * ? *)"
# }


# Rule 3 - RDS Idle (CPU < 5%)
resource "aws_cloudwatch_event_rule" "rds_idle_rule" {
  name = "capture-rds-idle-alarm"
  description = "Trigger action when RDS instance is idle"
  event_pattern = jsonencode({
    source = ["aws.cloudwatch"]
    detail-type = ["CloudWatch Alarm State Change"]
    detail = {
        alarmName = [aws_cloudwatch_metric_alarm.rds_idle.alarm_name]
        state = {
            value = ["ALARM"]
        }
    }
  })
}

# # Rule 4 - RDS Zero Connections
# resource "aws_cloudwatch_event_rule" "rds_zero_conn_rule" {
#   name = "capture-rds-zero-connections-alarm"
#   description = "Trigger action when RDS has zero connections"
#   event_pattern = jsonencode({
#     source = ["aws.cloudwatch"]
#     detail-type = ["CloudWatch Alarm State Change"]
#     detail = {
#         alarmName = [aws_cloudwatch_metric_alarm.rds_zero_connections.alarm_name]
#         state = {
#             value = ["ALARM"]
#         }
#     }
#   })
# }

# Rule 5 - S3 Unused (AllRequests = 0 for 10mins)
resource "aws_cloudwatch_event_rule" "s3_unused_rule" {
  name = "capture-s3-unused-alarm"
  description = "Trigger action when S3 bucket has no requests for 24 hours"
  event_pattern = jsonencode({
    source = ["aws.cloudwatch"]
    detail-type = ["CloudWatch Alarm State Change"]
    detail = {
        alarmName = [aws_cloudwatch_metric_alarm.s3_ghost_bucket.alarm_name]
        state = {
            value = ["ALARM"]
        }
    }
  })
}
