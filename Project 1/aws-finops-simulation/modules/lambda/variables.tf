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

variable "ec2_idle_rule_arn" {
  type = string
  description = "ARN of idle ec2 rule"
}


variable "ec2_overload_rule_arn" {
  type = string
  description = "ARN of overload ec2 rule"
}

variable "rds_idle_rule_arn" {
  type = string
  description = "ARN of idle rds rule"
}

variable "rds_zero_conn_rule" {
  type = string
  description = "ARN of rds zero connection rule"
}

variable "s3_unused_rule" {
  type = string
  description = "ARM of unused s3 rule"
}