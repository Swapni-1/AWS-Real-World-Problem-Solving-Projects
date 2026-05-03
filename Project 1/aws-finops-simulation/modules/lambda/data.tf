data "archive_file" "lambda_zip" {
  type = "zip"
  output_path = "${path.module}/functions/lambda_package.zip"

  source_dir = "${path.module}/functions/"
}

data "aws_caller_identity" "current" {}