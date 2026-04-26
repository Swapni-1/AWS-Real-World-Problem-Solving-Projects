# 1. WS_EC2 Security Group

resource "aws_security_group" "ws_ec2_sg" {
  name = "${var.project_name}-ws-ec2-sg"
  description = "Allow HTTP and SSH traffic"
  vpc_id = var.vpc_id

  # Inbound HTTP
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound: Everything is allowed
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-web-server-ec2"
    Role = "web-tier"
    Workload = "ec2"
    Access = "public"
    TrafficType = "http"
    Purpose = "web-server-access"
    AutoStop = "true"
    Schedule = "9-21"
    Criticality = "medium"
  }

}

# 2. RDS Security Group

resource "aws_security_group" "rds_sg" {
  name = "${var.project_name}-rds-sg"
  description = "Allow traffic from EC2 SG only"
  vpc_id = var.vpc_id

  # Inbound 
  ingress {
    from_port = 3306
    to_port = 3306

    protocol = "tcp"
    security_groups = [aws_security_group.ws_ec2_sg.id]
  }

  # Outbound: Everything is allowed
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-rds"
    Role = "database-tier"
    Workload = "rds"
    Access = "private"
    TrafficType = "mysql"
    Purpose = "database-access"
    Utilization = "low"
    Rightsize = "pending"
    Criticality = "high"
  }
}



