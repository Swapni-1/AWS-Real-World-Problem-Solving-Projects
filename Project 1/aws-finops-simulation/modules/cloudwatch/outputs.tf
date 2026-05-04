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

output "rds_idle_scheduler_rule_arn" {
  value = aws_scheduler_schedule.rds_stop_low_cpu.arn
}

output "s3_unused_scheduler_rule_arn" {
  value = aws_scheduler_schedule.s3_cleanup.arn
}