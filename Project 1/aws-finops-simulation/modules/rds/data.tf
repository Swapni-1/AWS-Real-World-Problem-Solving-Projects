data "aws_ssm_parameter" "db_username" {
  name = var.db_username
  with_decryption = true
}

data "aws_ssm_parameter" "db_password" {
  name = var.db_password
  with_decryption = true
}