variable "ami-id" {
  default = "ami-0aa31b568c1e8d622"
  type = string
}

variable "instance_type" {
  default = "t3.micro"
  type = string
}

variable "vpc_id" {
  type = string
  default = "Id of VPC"
}

variable "public_subnet_ids" {
  description = "Multiple Id of public subnet"
  type = list(string)
}

variable "private_subnet_ids" {
  description = "Multiple Id of private subnet"
  type = list(string)
}

variable "private_subnet_1_id" {
  description = "ID of public subnet"
  type = string
}

variable "alb_sg_id" {
  type = string
  description = "Id of ALB (Application Load Balancer)"
}

variable "ws-ec2-sg-id" {
  description = "ID of web server ec2 security group"
  type = string
}


variable "ec2_instance_profile_name" {
  description = "Name of ec2 instance profile"
  type = string
}

variable "website_directory" {
  default = "/var/www/html"
  description = "directory path of website"
  type = string
}


variable "github_repository" {
  default = "https://github.com/Swapni-1/HubSpot-Homepage.git"
  description = "Github repo link"
  type = string
}
