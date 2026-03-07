# VPC creation
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "devops-vpc"
  }
}

# IGW creation
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
}

# Public subnet A
resource "aws_subnet" "subnetA" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
}
# Public subnet B
resource "aws_subnet" "subnetB" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true
}
# Route table creation
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main_vpc.id
}

# IGW integrated via routes
resource "aws_route" "internet_access" {

  route_table_id         = aws_route_table.rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Subnet associations
resource "aws_route_table_association" "A" {
  subnet_id      = aws_subnet.subnetA.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "B" {
  subnet_id      = aws_subnet.subnetB.id
  route_table_id = aws_route_table.rt.id
}
# Security group creation
resource "aws_security_group" "web_sg" {

  vpc_id = aws_vpc.main_vpc.id

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
}
# S3 Bucket creation
resource "aws_s3_bucket" "app_bucket" {
  bucket = var.bucket_name
}

# EC2 instance with launch template and docker installation
resource "aws_launch_template" "web_template" {

  image_id      = var.ami_id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = base64encode(<<EOF
#!/bin/bash
sudo apt update -y
sudo apt install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker
docker run -d -p 80:80 nginx
EOF
)
}

# Load balancer creation
resource "aws_lb" "app_lb" {

  name               = "devops-alb"
  load_balancer_type = "application"

  subnets = [
    aws_subnet.subnetA.id,
    aws_subnet.subnetB.id
  ]

  security_groups = [aws_security_group.web_sg.id]
}

# Target group creation
resource "aws_lb_target_group" "tg" {

  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main_vpc.id
}

# Load balancer Listener
resource "aws_lb_listener" "listener" {

  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

# ASG creation
resource "aws_autoscaling_group" "asg" {

  desired_capacity = 2
  max_size         = 3
  min_size         = 1

  vpc_zone_identifier = [
    aws_subnet.subnetA.id,
    aws_subnet.subnetB.id
  ]

  launch_template {
    id      = aws_launch_template.web_template.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.tg.arn]
}