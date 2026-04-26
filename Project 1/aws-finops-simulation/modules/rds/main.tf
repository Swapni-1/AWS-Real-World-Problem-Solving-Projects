resource "aws_db_subnet_group" "db_net" {
  name = "main-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "db-subnet-group"
    Tier = "database"
    SubnetType = "private"
    Purpose = "rds-networking"
  }
}

resource "aws_db_instance" "web_server-db" {
  engine = var.engine_name
  instance_class = var.db_instance_classname
  engine_version = var.engine_version

  identifier = "database-1"

  username = data.aws_ssm_parameter.db_username.value
  password = data.aws_ssm_parameter.db_password.value
  port = "3306"
  skip_final_snapshot = true

  allocated_storage = 20
  storage_type = "gp2"
  
  # security group connection
  db_subnet_group_name = aws_db_subnet_group.db_net.name

  # subnet group connection
  vpc_security_group_ids = [var.rds_sg_id]

  tags = {
    Name = "overprovisioned-rds"

    Role = "database-tier"
    Workload = "rds"
    Tier = "database"
    SubnetType = "private"

    Purpose = "cost-simulation"
    Scenario = "overprovisioned-database"

    Utilization = "low"
    Rightsize = "pending"
    Optimization = "required"

    Access = "internal"
    TrafficType = "mysql"

    Criticality = "high"
    DataType = "application-db"

    AutoStop = "false"
  }
}