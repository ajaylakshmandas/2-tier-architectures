# Data block to fetch the latest Ubuntu AMI
data "aws_ami" "latest_ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}


resource "aws_instance" "machine" {
    count = var.count-ec2
    ami = data.aws_ami.latest_ubuntu.id
    instance_type = var.instancetype
    subnet_id = count.index == 0 ? aws_subnet.public.id : aws_subnet.private.id 
    vpc_security_group_ids = [aws_security_group.sg.id]

    tags = {
        Name = count.index == 0 ? "publicinstance" : "privateinstance"
    }
}


resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.tireVPC.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "security-group"
  }
}
