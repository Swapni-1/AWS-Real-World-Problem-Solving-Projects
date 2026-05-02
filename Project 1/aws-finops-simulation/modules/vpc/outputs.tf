output "vpc_outputs" {
  value = {
    vpc_id = aws_vpc.my_vpc.id
    public_subnet_1_id = aws_subnet.public_subnet_1.id
    public_subnet_2_id = aws_subnet.public_subnet_2.id
    private_subnet_1_id = aws_subnet.private_subnet_1.id
    private_subnet_2_id = aws_subnet.private_subnet_2.id
    internet_gateway_id = aws_internet_gateway.igw.id
    route_table_id = aws_route_table.rt.id
  }
}