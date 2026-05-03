# This module creates an IAM role and policy for the RDS start/stop scheduler.
resource "aws_iam_role" "rds_scheduler_role" {
  name = "rds-start-stop-scheduler-role"

  assume_role_policy = jsonencode({ 
    Version = "2012-10-17"
    Statement = [{ 
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "scheduler.amazonaws.com"
      }
    }]
  })
  
}

resource "aws_iam_role_policy" "rds_scheduler_policy" {
  name = "rds-scheduler-policy"
  role = aws_iam_role.rds_scheduler_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
            "rds:StartDBInstance",
            "rds:StopDBInstance"
        ]
        Resource = "arn:aws:rds:${var.aws_region}:${data.aws_caller_identity.current.account_id}:db:${var.rds_instance_identifier}"
      }
    ]
  })
}

# Create a scheduler to start RDS instance at 8:45 AM ITC daily
resource "aws_scheduler_schedule" "rds_start_daily" {
  name = "start-rds-daily-8-45-am-ist"
  group_name = "default"
  description = "Start RDS instance at 8:45 AM IST daily"
  schedule_expression = "cron(45 8 * * ? *)"
  schedule_expression_timezone = "Asia/Kolkata"
  flexible_time_window {
    mode = "OFF"
  }
  target {
    arn = "arn:aws:scheduler:::aws-sdk:rds:startDBInstance"
    role_arn = aws_iam_role.rds_scheduler_role.arn
    input = jsonencode({
      DbInstanceIdentifier = var.rds_instance_identifier
    })
  }
}

# Create a scheduler to stop RDS instance at 9:00 PM ITC daily
resource "aws_scheduler_schedule" "rds_stop_daily" {
  name = "stop-rds-daily-9-00-pm-ist"
  group_name = "default"
  description = "Stop RDS instance at 9:00 PM IST daily"
  schedule_expression = "cron(0 21 * * ? *)"
  schedule_expression_timezone = "Asia/Kolkata"
  flexible_time_window {
    mode = "OFF"
  }
  target {
    arn = "arn:aws:scheduler:::aws-sdk:rds:stopDBInstance"
    role_arn = aws_iam_role.rds_scheduler_role.arn
    input = jsonencode({
      DbInstanceIdentifier = var.rds_instance_identifier
    })
  }
}   