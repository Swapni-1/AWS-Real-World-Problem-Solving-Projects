# resource "aws_cloudwatch_event_target" "ec2_idle_target" {
#     rule = aws_cloudwatch_event_rule.ec2_idle_rule.name
#     arn = var.aws_lambda_function_alarm_processor_arn
#     target_id = "EC2IdleTarget"
# }

# resource "aws_cloudwatch_event_target" "ec2_start_target" {
#   rule = aws_cloudwatch_event_rule.ec2_start_at_9am.name
#   arn =  var.aws_lambda_function_alarm_processor_arn
#   target_id = "EC2StartTarget"
# }

# resource "aws_cloudwatch_event_target" "rds_idle_target" {
#   rule = aws_cloudwatch_event_rule.rds_idle_rule.name
#   arn = var.aws_lambda_function_alarm_processor_arn
#   target_id = "RDSIdleTarget"
# }

# resource "aws_cloudwatch_event_target" "rds_zero_conn_target" {
#   rule = aws_cloudwatch_event_rule.rds_zero_conn_rule.name
#   arn = var.aws_lambda_function_alarm_processor_arn
#   target_id = "RDSZeroConnTarget"
# }

# resource "aws_cloudwatch_event_target" "s3_unused_target" {
#   rule = aws_cloudwatch_event_rule.s3_unused_rule.name
#   arn = var.aws_lambda_function_alarm_processor_arn
#   target_id = "S3UnusedTarget"
# }
