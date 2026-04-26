variable "engine_name" {
  default = "mysql"
  type = string
}

variable "engine_version" {
  default = "8.0" # stable version
  type = string
}

variable "db_instance_classname" {
  default = "db.t3.micro"
  type = string
}

variable "db_username" {
  default = "db_username"
  type = string 
}

variable "db_password" {
 default =  "db_password"
 type = string
}

variable "private_subnet_ids" {
  description = "IDs of Private Subnets"
  type = list(string)
}


variable "rds_sg_id" {
  default = "ID of rds security group"
}