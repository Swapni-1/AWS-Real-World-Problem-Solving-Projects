# Lambda iam role

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

# Lambda alarm policy

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

# Lambda Function

resource "aws_lambda_function" "alarm_processor" {
  filename = var.file_name
  function_name = var.function_name
  role = aws_iam_role.alarm_lambda_role.arn
  handler = var.handler
  runtime = var.runtime_environment
  memory_size = 128
  timeout = 30

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      EC2_INSTANCE_ID = var.ec2_instances_id
      RDS_INSTANCE_ID = var.rds_instance_identifier
      S3_BUCKET = var.s3_bucket_name
    }
  }
}

# lambda permission

resource "aws_lambda_permission" "allow_morning_start" {
  statement_id = "Allow-StartEC2Schedule"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.alarm_processor.function_name
  principal = "events.amazonaws.com"
  source_arn = var.ec2_idle_rule_arn
}

resource "aws_lambda_permission" "allow_all_rules" {
  for_each = [ 
    var.ec2_idle_rule_arn,
    var.ec2_overload_rule_arn,
    var.rds_idle_rule_arn,
    var.rds_zero_conn_rule,
    var.s3_unused_rule
   ]

   statement_id = "Allow-${basename(each.key)}"
   action = "lambda:InvokeFunction"
   function_name = aws_lambda_function.alarm_processor.function_name
   principal = "events.amazonaws.com"
   source_arn = each.key
}