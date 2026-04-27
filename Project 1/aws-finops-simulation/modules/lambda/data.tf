data "archive_file" "lambda_zip" {
  type = "zip"
  output_path = "${path.module}/functions/${var.file_name}"

  source {
    content = file("${path.module}/functions/index.py")
    filename = "index.py"
  }
}