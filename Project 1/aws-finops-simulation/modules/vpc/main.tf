# ===========|VPC|===============
# ===============================
resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true 
  enable_dns_support = true 

  tags = {
    Name = "finops-vpc"
    Purpose = "networking"
    Layer = "network"
  }
}
# ===============================

# ============|Pubic Subnets|==============
# =========================================
resource "aws_subnet" "public_subnet_1" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = var.public_subnet_1_cidr
  availability_zone = "ap-south-2a"

  tags = {
    Name = "public-subnet"
    Tier = "public"
    Role = "web-tier"
    Workload = "alb"
    Access = "internet-facing"
  }
}


resource "aws_subnet" "public_subnet_2" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = var.public_subnet_2_cidr
  availability_zone = "ap-south-2b"

  tags = {
    Name = "public-subnet"
    Tier = "public"
    Role = "web-tier"
    Workload = "alb"
    Access = "internet-facing"
  }
}
# =========================================

# ============|Pubic Subnets|==============
# =========================================
resource "aws_subnet" "private_subnet_1" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = var.private_subnet_1_cidr
  availability_zone = "ap-south-2a"

  tags = {
    Name = "private-subnet"
    Tier = "private"
    Role = "database-tier"
    Workload = "ec2 and rds"
    Access = "internal"  
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = var.private_subnet_2_cidr
  availability_zone = "ap-south-2b"

  tags = {
    Name = "private-subnet"
    Tier = "private"
    Role = "database-tier"
    Workload = "rds"
    Access = "internal"  
  }
}
# =========================================

# ============|Internet Gateway|============
# ===========================================
resource "aws_internet_gateway" "igw" {
   vpc_id = aws_vpc.my_vpc.id

   tags = {
     Name = "igw-finops"
     Purpose = "internet-access"
   }
}
# =============================================

# ============| Public Route Table |============ 
# ==============================================
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_vpc.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-rt"
    Purpose = "routing"
  }
}
# ===============================================

# =======| Public Route Table Associations |=============
# =======================================================
resource "aws_route_table_association" "public_rta_1" {
  subnet_id = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rta_2" {
  subnet_id = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}
# =======================================================

# ===========|Private Route Table|===============
# ===============================================
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "private-rt"
  }
}
# ==============================================

# ==========| Private Route Table Association |==========
# ========================================================
resource "aws_route_table_association" "private_rta_1" {
  subnet_id = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_rta_2" {
  subnet_id = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_rt.id
}
# ========================================================

