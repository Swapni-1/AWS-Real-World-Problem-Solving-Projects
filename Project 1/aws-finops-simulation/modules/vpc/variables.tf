variable "vpc_cidr" {
  default = "10.0.0.0/16"
  type = string
  description = "cidr value for vpc"
}

variable "private_subnet_1_cidr" {
  default = "10.0.1.0/24"
  type = string
  description = "cidr value for private subnet"
}

variable "private_subnet_2_cidr" {
  default = "10.0.3.0/24"
  type = string
  description = "cidr value for private subnet"
}

variable "public_subnet_cidr" {
  default = "10.0.2.0/24"
  type = string
  description = "cidr value for public subnet"
}
