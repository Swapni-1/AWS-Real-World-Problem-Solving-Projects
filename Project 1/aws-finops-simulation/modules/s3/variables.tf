variable "bucket_name" {
  default = "ec2_s3_profile"
  type = string
}

variable "vpc_id" {
  type = string
  default = "ID of VPC"
}

variable "aws_region" {
  type = string
  default = "value of current region"
}

variable "route_table_id" {
  type = string
  default = "Id of route table"
}