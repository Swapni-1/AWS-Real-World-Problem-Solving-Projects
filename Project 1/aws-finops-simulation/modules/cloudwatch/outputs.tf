output "dashboard_name" {
  description = "ARN of the CloudWatch dashboard"
  value = aws_cloudwatch_dashboard.central_monitoring.dashboard_arn
}

output "dashboard_arn" {
  description = "Name of the dashboard"
  value = aws_cloudwatch_dashboard.central_monitoring.dashboard_name
}
