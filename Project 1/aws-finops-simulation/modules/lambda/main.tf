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