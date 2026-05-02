module "my_vpc" {
  source = "../../modules/vpc"
}

module "my_sg" {
  source = "../../modules/security-group"
  vpc_id = module.my_vpc.vpc_outputs.vpc_id
}

module "my_s3_bucket" {
  source = "../../modules/s3"
}

# module "ec2_instances" {
#   source                    = "../../modules/ec2"
#   ec2_instance_profile_name = module.my_s3_bucket.s3_outputs.ec2_instance_profile_name

#   public_subnet_id = module.my_vpc.vpc_outputs.public_subnet_id
#   ws-ec2-sg-id     = module.my_sg.security_group_outputs.ws_sg_id
# }

module "my_rds" {
  source             = "../../modules/rds"
  private_subnet_ids = [module.my_vpc.vpc_outputs.private_subnet_1_id, module.my_vpc.vpc_outputs.private_subnet_2_id]
  rds_sg_id          = module.my_sg.security_group_outputs.rds_sg_id
}

module "my_cloudwatch" {
  source                  = "../../modules/cloudwatch"
  # ec2_instances_id        = module.ec2_instances.ec2_outputs.web_server_id
  rds_instance_id         = module.my_rds.rds_outputs.db_instance_id  
  # rds_instance_identifier = module.my_rds.rds_outputs.db_instance_identifier   
  s3_bucket_name          = module.my_s3_bucket.s3_outputs.bucket_name  
  # sns_topic_arn           = module.my_sns.sns_topic_arn  
}

# module "my_sns" {
#   source = "../../modules/sns"
# }