output "security_group_outputs" {
  value = {
    ws_sg_id = aws_security_group.ws_ec2_sg.id
    rds_sg_id = aws_security_group.rds_sg.id
  }
}