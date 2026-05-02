# resource "aws_iam_role" "lambda_role" {
  
# }

# resource "aws_iam_role_policy" "name" {
  
# }

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

