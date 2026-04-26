
# 1. Web Server
resource "aws_instance" "web_server" {
  ami = var.ami-id
  instance_type = var.instance_type
  
  # subnet group connection
  subnet_id = var.public_subnet_id
  
  # security group connection
  vpc_security_group_ids = [var.ws-ec2-sg-id]

  # iam instance profile
  iam_instance_profile = var.ec2_instance_profile_name

  # Auto assign public ipv4 address on instance launch
  associate_public_ip_address = true

  # user data script for automated website setup
  user_data = data.cloudinit_config.combined_scripts.rendered
  
  tags = {
    Name = "web-server-idle-ec2"

    Role = "web-server"
    Workload = "ec2"
    Tier = "web"
    SubnetType = "public"

    Purpose = "idle-simulation"
    TrafficType = "user-facing"
    TrafficPattern = "predictable"

    Schedule = "9-21"
    AutoStop = "true"
    IdleThreshold = "15"

    Utilization="low"
    Optimization = "required"

    Criticality = "medium"
  }
}
