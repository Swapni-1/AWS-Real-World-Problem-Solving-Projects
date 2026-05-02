resource "aws_lambda_permission" "allow_ec2_morning_start" {
    statement_id = "Allow-EC2StartSchedule"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.alarm_processor.function_name
    principal = "events.amazonaws.com"
    source_arn = var.ec2_start_rule_arn
}

resource "aws_lambda_permission" "allow_idle_ec2_stop" {
    statement_id = "Allow-EC2Stop"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.alarm_processor.function_name
    principal = "events.amazonaws.com"
    source_arn = var.ec2_idle_rule_arn
}

resource "aws_lambda_permission" "allow_idle_rds_terminate" {
    statement_id = "Allow-IdleRDSTerminate"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.alarm_processor.function_name
    principal = "events.amazonaws.com"
    source_arn = var.rds_idle_rule_arn
}

resource "aws_lambda_permission" "allow_rds_zero_connections_terminate" {
    statement_id = "Allow-ZeroConnectionRDSTerminate"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.alarm_processor.function_name
    principal = "events.amazonaws.com"
    source_arn = var.rds_zero_conn_rule_arn
}

resource "aws_lambda_permission" "allow_unused_s3_object_delete" {
    statement_id = "Allow-UnusedS3ObjectDelete"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.alarm_processor.function_name
    principal = "events.amazonaws.com"
    source_arn = var.s3_unused_rule_arn
}

resource "aws_lambda_permission" "allow_scheduler_idle_rds_terminate" {
    statement_id = "Allow-IdleRDSTerminateScheduler"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.alarm_processor.function_name
    principal = "scheduler.amazonaws.com"
    source_arn = var.ec2_start_rule_arn
}

resource "aws_lambda_permission" "allow_scheduler_rds_zero_connections_terminate" {
    statement_id = "Allow-ZeroConnectionRDSTerminateScheduler"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.alarm_processor.function_name
    principal = "scheduler.amazonaws.com"
    source_arn = var.ec2_start_rule_arn
}