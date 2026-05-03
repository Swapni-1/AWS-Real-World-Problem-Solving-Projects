# Lambda IAM Role
resource "aws_iam_role" "lambda_finops_role" {
  name = "lambda-finops-automation-role"

  assume_role_policy = jsonencode({ 
    Version = "2012-10-17"
    Statement = [{ 
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# RDS Optimizer Lambda IAM Policy
resource "aws_iam_policy" "rds_lambda_optimizer_policy" {
  name = "rds-lambda-optimizer-policy"
  #role = aws_iam_role.lambda_finops_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # 1. Monitoring and Discovery Permissions
      {
        Effect = "Allow"
        Action = [
          "rds:DescribeDBInstances",
          "rds:ListTagsForResource",
        ]
        Resource = "*"
      },

      # 2. Stop and Terminate Actions
      {
        Effect = "Allow"
        Action = [
          "rds:StopDBInstance",
          "rds:DeleteDBInstance"
        ]
        Resource = "arn:aws:rds:${var.aws_region}:${data.aws_caller_identity.current.account_id}:db:${var.rds_instance_identifier}"
      },

      # 3.Safety First
      {
        Effect = "Allow"
        Action = [
          "rds:CreateDBSnapshot",
        ]
        Resource = "arn:aws:rds:${var.aws_region}:${data.aws_caller_identity.current.account_id}:snapshot:*"
      },

      # 4. CloudWatch Logs Permissions
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ] 
  })
}

# S3 Optimizer Lambda IAM Policy
resource "aws_iam_policy" "s3_lambda_optimizer_policy" {
  name = "s3-idle-cleaner-and-lcp-policy"
  # role = aws_iam_role.lambda_finops_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # 1. Metadata and Tagging Permissions
      {
        Effect = "Allow"
        Action   = [
          "s3:GetBucketTagging",
          "s3:PutBucketTagging",
          "s3:GetLifecycleConfiguration",
          "s3:PutLifecycleConfiguration"
        ]
        Resource = "arn:aws:s3:::${var.s3_bucket_name}"
      },

      # 2. Activity Check
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:GetMetricData"
        ]
        Resource = "*"
      },

      # 3. Data Cleaning
      {
        Effect = "Allow"
        Action = [
          "s3:DeleteObject",
          "s3:DeleteObjectVersion",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.s3_bucket_name}",
          "arn:aws:s3:::${var.s3_bucket_name}/*"
        ]
      },

      # 4. Logs 
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# RDS Policy Attachment
resource "aws_iam_role_policy_attachment" "attact_rds" {
  role       = aws_iam_role.lambda_finops_role.name
  policy_arn = aws_iam_policy.rds_lambda_optimizer_policy.arn  
}

# S3 Policy Attachment
resource "aws_iam_role_policy_attachment" "attach_s3" {
  role       = aws_iam_role.lambda_finops_role.name
  policy_arn = aws_iam_policy.s3_lambda_optimizer_policy.id
} 

resource "aws_lambda_function" "rds_optimizer" {
  filename = data.archive_file.lambda_zip.output_path
  function_name = "rds-idle-optimizer" 
  role = aws_iam_role.lambda_finops_role.arn
  handler = "rds_optimizer.lambda_handler"
  runtime = var.runtime_environment
  timeout = 60

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      RDS_INSTANCE_ID = var.rds_instance_identifier
    }
  }
}

resource "aws_lambda_function" "s3_optimizer" {
  filename = data.archive_file.lambda_zip.output_path
  function_name = "s3-activity-optimizer" 
  role = aws_iam_role.lambda_finops_role.arn
  handler = "s3_optimizer.lambda_handler"
  runtime = var.runtime_environment
  timeout = 60

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      S3_BUCKET_NAME = var.s3_bucket_name
    }
  }
}

# Lambda Permission for EventBridge to invoke Lambda for RDS Optimizer
resource "aws_lambda_permission" "allow_eventbridge_rds" {
  statement_id = "AllowExecutionFromEventBridgeRDS"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rds_optimizer.function_name
  principal = "events.amazonaws.com"
  source_arn = var.rds_idle_rule_arn
}

# Lambda Permission for EventBridge to invoke Lambda for S3 Optimizer
resource "aws_lambda_permission" "allow_eventbridge_s3" {
  statement_id = "AllowExecutionFromEventBridgeS3"
  action = "lambda:InvokeFunction"    
  function_name = aws_lambda_function.s3_optimizer.function_name  
  principal = "events.amazonaws.com"  
  source_arn = var.s3_unused_rule_arn
} 