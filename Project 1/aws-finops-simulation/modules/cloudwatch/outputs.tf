output "dashboard_name" {
  description = "ARN of the CloudWatch dashboard"
  value = aws_cloudwatch_dashboard.finops_dashboard.dashboard_arn
}

output "dashboard_arn" {
  description = "Name of the dashboard"
  value = aws_cloudwatch_dashboard.finops_dashboard.dashboard_name
}

output "rds_idle_rule_arn" {
  value = aws_cloudwatch_event_rule.rds_idle_rule.arn
}

output "s3_unused_rule_arn" {
  value = aws_cloudwatch_event_rule.s3_unused_rule.arn
}