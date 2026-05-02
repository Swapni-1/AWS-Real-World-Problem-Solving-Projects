# EC2 Launch Template
resource "aws_launch_template" "lt" {
  name_prefix = "web-lt-"
  image_id = var.ami-id
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = false
    security_groups = [var.ws-ec2-sg-id]
  }

  user_data = data.cloudinit_config.combined_scripts.rendered
}

# Load Balancer Target Group
resource "aws_lb_target_group" "tg" {
  name = "web-tg"
  port = 80
  protocol = "HTTP"
  vpc_id = var.vpc_id

  health_check {
    path = "/"
  }
}

# ALB (Application Load Balancer)
resource "aws_lb" "alb" {
  name = "web-alb"
  load_balancer_type = "application"
  security_groups = [var.alb_sg_id]
  subnets = var.public_subnet_ids 
}

# Listener
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "asg" {
  name = "web-asg"
  desired_capacity = 1
  min_size = 1
  max_size = 3
  vpc_zone_identifier = var.private_subnet_ids

  launch_template {
    id = aws_launch_template.lt.id
    version = aws_launch_template.lt.latest_version
  }

  target_group_arns = [aws_lb_target_group.tg.arn]
  health_check_type = "ELB"
  health_check_grace_period = 300
}

# Scaling Policies

# Scale OUT (+1)
resource "aws_autoscaling_policy" "scale_out" {
  name = "scale-out"
  scaling_adjustment = 1
  adjustment_type = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  cooldown = 300
}

# Scale IN (-1)
resource "aws_autoscaling_policy" "scale_in" {
  name = "scale-in"
  scaling_adjustment = -1
  adjustment_type = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  cooldown = 300
}

# # Web Server
# resource "aws_instance" "web_server" {
#   ami = var.ami-id
#   instance_type = var.instance_type
  
#   # subnet group connection
#   subnet_id = var.private_subnet_1_id
#   # security group connection
#   vpc_security_group_ids = [var.ws-ec2-sg-id]

#   # iam instance profile
#   iam_instance_profile = var.ec2_instance_profile_name

#   # Auto assign public ipv4 address on instance launch
#   associate_public_ip_address = false

#   # user data script for automated website setup
#   user_data = data.cloudinit_config.combined_scripts.rendered
  
#   tags = {
#     Name = "web-server-idle-ec2"

#     Role = "web-server"
#     Workload = "ec2"
#     Tier = "web"
#     SubnetType = "public"

#     Purpose = "idle-simulation"
#     TrafficType = "user-facing"
#     TrafficPattern = "predictable"

#     Schedule = "9-21"
#     AutoStop = "true"
#     IdleThreshold = "15"

#     Utilization="low"
#     Optimization = "required"

#     Criticality = "medium"
#   }
# }
