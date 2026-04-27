variable "ec2_instances_id" {
  description = "Id of EC2 instance"
  type =  string
}

variable "rds_instance_identifier" {
  description = "Unique identifier of rds instance"
  type = string
}

variable "s3_bucket_name" {
  description = "Name of S3 Bucket"
  type = string
}

variable "file_name" {
  default = "lambda_alarm_processor.zip"
  type = string
  description = "Name of python zip file"
}

variable "function_name" {
  default = "cloudwatch-alarm-actions"
  type = string
  description = "Name of function"
}

variable "runtime_environment" {
  default = "python3.12"
  type = string
  description = "Name and version of runtime environment"
}

variable "handler" {
  default = "index.lambda_handler"
  type = string
  description = "Name of handler (function)"
}