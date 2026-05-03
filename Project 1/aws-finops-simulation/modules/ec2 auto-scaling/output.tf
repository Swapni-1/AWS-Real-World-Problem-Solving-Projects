output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value = aws_autoscaling_group.asg.name
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value = aws_lb.alb.dns_name
}