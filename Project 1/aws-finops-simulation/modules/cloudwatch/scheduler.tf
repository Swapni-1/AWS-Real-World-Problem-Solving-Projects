# resource "aws_scheduler_schedule" "rds_schedule" {
#   name = "rds-idle-check-10min"

#   schedule_expression = "rate(10 minutes)"

#   flexible_time_window {
#     mode = "OFF"
#   }

#   target {
#     arn = var.aws_lambda_function_alarm_processor_arn
#     role_arn = var.aws_iam_lambda_role_arn

#     input = jsonencode({
#         action = "rds-idle"
#     }) 
#   }
# }

# resource "aws_scheduler_schedule" "rds_zero_conn_scheduler" {
#   name = "rds-zero-connections-check-60min"

#   schedule_expression = "rate(60 minutes)"

#   flexible_time_window {
#     mode = "OFF"
#   }

#   target {
#     arn = var.aws_lambda_function_alarm_processor_arn
#     role_arn = var.aws_iam_lambda_role_arn

#     input = jsonencode({
#         action = "rds-zero-connections"
#     }) 
#   }
# }