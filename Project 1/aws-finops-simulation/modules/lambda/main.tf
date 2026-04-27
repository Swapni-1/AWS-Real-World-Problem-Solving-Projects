resource "aws_iam_role" "alarm_lambda_role" {
  name = "alarm-action-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Effect = "Allow"
            Principal = {
                Service = "lambda.amazonaws.com"
            }
            Action = "sts:AssumeRole"
        }
    ]
  })
}

resource "aws_iam_role_policy" "alarm_lambda_role" {
  name = "alarm-action-policy"
  role = aws_iam_role.alarm_lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Effect = "Allow"
            Action = [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ]
            Resource = "arn:aws:logs:*:*:*"
        },
        {
            Effect = "Allow"
            Action = [
                "ec2:StopInstances"
            ]
            Resource = "*"
            Condition = {
                StringEquals = {
                    "ec2:InstanceId" = var.ec2_instances_id
                }
            }
        },
        {
            Effect = "Allow"
            Action = [
               "rds:ModifyDBInstance",
               "rds:DescribeDBInstance",
               "rds:DeleteDBInstance",
               "rds:CreateDBSnapshot"
            ]
            Resource = "*"
        },
        {
            Effect = "Allow"
            Action = [
               "s3:PutBucketLifecycleConfiguration",
               "s3:GetBucketLifecycleConfiguration",
               "s3:ListBucket",
               "s3:GetBucketLocation",
               "s3:DeleteBucket"
            ]
            Resource = "arn:aws:s3:::${var.s3_bucket_name}"
        },
        {
            Effect = "Allow"
            Action = [
                "s3:DeleteObject",
                "s3:GetObject"
            ]
            Resource = "arn:aws:s3:::${var.s3_bucket_name}/*"
        }
    ]
  })
}

resource "aws_lambda_function" "alarm_processor" {
  filename = var.file_name
  function_name = var.function_name
  role = aws_iam_role.alarm_lambda_role.arn
  handler = var.handler
  runtime = var.runtime_environment
  memory_size = 128
  timeout = 30

  source_code_hash = filebase64sha256("${var.file_name}")

  environment {
    variables = {
      EC2_INSTANCE_ID = var.ec2_instances_id
      RDS_INSTANCE_ID = var.rds_instance_identifier
      S3_BUCKET = var.s3_bucket_name
    }
  }
}

