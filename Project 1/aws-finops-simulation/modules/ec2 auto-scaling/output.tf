output "ec2_outputs" {
  value = {
    web_server_id = aws_instance.web_server.id
    web_server_public_ip = aws_instance.web_server.public_ip
  }
}