# Creating Security Group for Load Balancer
resource "aws_security_group" "lb_sg" {
  name        = "lb-security-group"
  description = "Security group for Load Balancer"
  vpc_id      = aws_vpc.tireVPC.id 

  ingress {
    from_port   = 80
    to_port     = 80
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
    Name = "lb-security-group"
  }
}

# Creating Load Balancer
resource "aws_lb" "app_lb" {
  name               = "2tier-app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [aws_subnet.public.id , aws_subnet.private.id]

  enable_deletion_protection = true

  tags = {
    Name        = "app-lb"
    Environment = "production"
  }
}

# Creating Target Group
resource "aws_lb_target_group" "app_tg" {
  name     = "app-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.tireVPC.id 

  health_check {
    interval            = 10
    path                = "/"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 5
    matcher             = "200"
  }

  tags = {
    Name = "app-target-group"
  }
}

# Creating Load Balancer Listener
resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_lb.arn  
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn 
  }
}

# Registering EC2 Instances with the Target Group
resource "aws_lb_target_group_attachment" "app_tg_attachment" {
  count             = 2
  target_group_arn  = aws_lb_target_group.app_tg.arn
  target_id         = aws_instance.machine[count.index].id
  port              = 80
}
