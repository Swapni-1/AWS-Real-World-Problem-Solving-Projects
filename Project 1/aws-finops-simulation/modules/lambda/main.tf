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
                "ec2:StopInstances",
                "ec2:DescribeInstances"
            ]
            Resource = "*"
        },
        {
            Effect = "Allow"
            Action = [
               "rds:StopDBInstance",
               "rds:ModifyDBInstance",
               "rds:DescribeDBInstance"
            ]
            Resource = "*"
        },
        {
            Effect = "Allow"
            Action = [
               "s3:PutBucketLifecycleConfiguration",
               "s3:GetBucketLifecycleConfiguration",
               "s3:ListBucket"
            ]
            Resource = "arn:aws:s3:::${var.s3_bucket_name}"
        },
        {
            Effect = "Allow"
            Action = [
                "s3:GetBucketLocation"
            ]
            Resource = "arn:aws:s3:::${var.s3_bucket_name}"
        }
    ]
  })
}