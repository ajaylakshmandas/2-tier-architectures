# Creating VPC
resource "aws_vpc" "tireVPC" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "2tiervpc"
  }
}

# Creating Internet Gateway to allow internet access
resource "aws_internet_gateway" "mygateway" {
  vpc_id = aws_vpc.tireVPC.id

  tags = {
    Name = "mygateway"
  }
}

# Creating Route Table to route internet traffic to public subnet
resource "aws_route_table" "publictb" {
  vpc_id = aws_vpc.tireVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mygateway.id
  }

  tags = {
    Name = "publictb"
  }
}

# Creating Public Subnet
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.tireVPC.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

# Creating Association between Route Table and Public Subnet
resource "aws_route_table_association" "publicassociation" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.publictb.id
}

# Creating Private Subnet
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.tireVPC.id 
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "private-subnet"
  }
}

# Creating Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
  vpc = true

  tags = {
    Name = "nat-eip"
  }
}

# Creating NAT Gateway in the Public Subnet
resource "aws_nat_gateway" "natgateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "natgateway"
  }
}

# Creating Route Table for Private Subnet to route traffic through NAT Gateway
resource "aws_route_table" "privatetb" {
  vpc_id = aws_vpc.tireVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgateway.id
  }

  tags = {
    Name = "privatetb"
  }
}

# Creating Association between Route Table and Private Subnet
resource "aws_route_table_association" "privateassociation" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.privatetb.id
}
