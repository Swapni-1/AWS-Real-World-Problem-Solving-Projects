output "db_instance_id" {
  value = aws_db_instance.web_server-db.id
}

output "db_instance_identifier" {
  value = aws_db_instance.web_server-db.identifier
}

output "db_endpoint" {
  value = aws_db_instance.web_server-db.endpoint
}

output "db_port" {
  value = aws_db_instance.web_server-db.port
}