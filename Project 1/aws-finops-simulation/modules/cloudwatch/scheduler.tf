# This module creates an IAM role and policy for the RDS start/stop scheduler.
resource "aws_iam_role" "scheduler_role" {
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

resource "aws_iam_role_policy" "scheduler_policy" {
  name = "rds-scheduler-policy"
  role = aws_iam_role.scheduler_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # RDS Permissions
        Effect = "Allow"
        Action = ["rds:StartDBInstance", "rds:StopDBInstance"]
        Resource = "arn:aws:rds:${var.aws_region}:${data.aws_caller_identity.current.account_id}:db:${var.rds_instance_identifier}"
      },
      {
        # Lambda Permissions (Bahut Zaroori)
        Effect = "Allow"
        Action = "lambda:InvokeFunction"
        Resource = [
          var.aws_lambda_function_rds_optimizer_arn,
          var.aws_lambda_function_s3_optimizer_arn
        ]
      },
      {
        # CloudWatch Permissions (Agar Lambda CPU check karega toh ye chahiye)
        Effect = "Allow"
        Action = "cloudwatch:GetMetricData"
        Resource = "*"
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
    role_arn = aws_iam_role.scheduler_role.arn
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
    role_arn = aws_iam_role.scheduler_role.arn
    input = jsonencode({
      DbInstanceIdentifier = var.rds_instance_identifier
    })
  }
}   

# create a scheduler to stop RDS instance when CPU is less than 5% for 20 mins
resource "aws_scheduler_schedule" "rds_stop_low_cpu" {
  name = "stop-rds-low-cpu"
  group_name = "default"
  description = "Stop RDS instance when CPU is less than 5% for 20 mins"
  schedule_expression = "rate(20 minutes)"
  flexible_time_window {
    mode = "OFF"
  }
  target {
    arn = var.aws_lambda_function_rds_optimizer_arn
    role_arn = aws_iam_role.scheduler_role.arn
    input = jsonencode({
      DbInstanceIdentifier = var.rds_instance_identifier
    })
  }
}

# create a scheduler to invoke lambda function when S3 Bucket is Unsued for 3 days
resource "aws_scheduler_schedule" "s3_cleanup" {
  name                = "s3-cleanup"
  group_name          = "default"
  description         = "Clean up S3 Bucket when it is unused for 3 days"
  schedule_expression = "rate(24 hours)" 
  
  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = var.aws_lambda_function_s3_optimizer_arn  
    role_arn = aws_iam_role.scheduler_role.arn          
    
    # ✅ FIXED: S3-specific input, NOT RDS
    input = jsonencode({
      S3BucketName = var.s3_bucket_name
    })
  }
}