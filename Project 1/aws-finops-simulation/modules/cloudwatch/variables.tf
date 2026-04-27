variable "aws_region" {
  description = "Value of current aws region"
  type = string
  default = "ap-south-2"
}

variable "ec2_instances_id" {
  description = "EC2 instance ID to monitor"
  type = string
}

variable "rds_instance_id" {
  description = "RDS instance id"
  type = string
}

variable "rds_instance_identifier" {
  description = "RDS instance identifier"
  type = string
}


variable "s3_bucket_name" {
  description = "S3 bucket name"
  type = string
}

variable "dashboard_name" {
  description = "Name of central dashboard"
  type = string
  default = "Central-Resource-Monitoring-Dashboard"
}

variable "sns_topic_arn" {
  description = "arn of sns topic"
  type = string
}

# variable "aws_lambda_function_alarm_processor_arn" {
#   description = "ARN value of lambda function"
#   type = string
# }
