output "rds_outputs" {
  value = {
    db_instance_id = aws_db_instance.web_server-db.id
    db_endpoint = aws_db_instance.web_server-db.endpoint
    db_port = aws_db_instance.web_server-db.port
  }
}