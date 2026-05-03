variable "bucket_name" {
  default = "ec2_s3_profile"
  type = string
}

variable "vpc_id" {
  type = string
  description = "ID of VPC"
}

variable "aws_region" {
  type = string
  default = "ap-south-2"
}

variable "public_route_table_id" {
  type = string
  description = "Id of public route table"
}

variable "private_route_table_id" {
  type = string
  description = "Id of private route table"
}