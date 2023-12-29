resource "aws_eip" "eip" {
   domain   = "vpc"
  tags = {
    Name = "nat"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id 
  subnet_id = aws_subnet.public-us-east-1a.id 

  tags = {
    Name = "nat"
  }

  depends_on = [ aws_internet_gateway.igw ]
}