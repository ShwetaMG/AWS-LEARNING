resource "aws_vpc" "myvpc" {
  cidr_block = var.cidr
  
}

resource "aws_subnet" "mysubnet1" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "mysubnet2" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1b"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "myIGateWay"{
  vpc_id = aws_vpc.myvpc.id

}

resource "aws_route_table" "myRouteTable" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myIGateWay.id
}
}

resource "aws_route_table_association" "myRT1" {
  subnet_id      = aws_subnet.mysubnet1.id
  route_table_id = aws_route_table.myRouteTable.id
}

resource "aws_route_table_association" "myRT2" {
  subnet_id      = aws_subnet.mysubnet2.id
  route_table_id = aws_route_table.myRouteTable.id
}

resource "aws_security_group" "allow_tls" {
  name        = "web-sg"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    description      = "HTTP from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  } 

  egress {
    description      = "All outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
}

tags = {
  Name = "web-sg"
}
}

resource "aws_s3_bucket" "mybucket" {
  bucket = "my-demo-bucket-terraform-29-05-2026"
}

resource "aws_instance" "myec2-1" {
  ami           = "ami-07a00cf47dbbc844c"
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.allow_tls.id]
  subnet_id = aws_subnet.mysubnet1.id
  user_data = file("userdata.sh")
 
}

resource "aws_instance" "myec2-2" {
  ami           = "ami-07a00cf47dbbc844c"
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.allow_tls.id]
  subnet_id = aws_subnet.mysubnet2.id
  user_data = file("userdata2.sh")
}


#create alb
resource "aws_lb" "myalb" {
  name               = "myalb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [aws_security_group.allow_tls.id]
  subnets         = [aws_subnet.mysubnet1.id, aws_subnet.mysubnet2.id]

}

resource "aws_lb_target_group" "tg" {
  name     = "myTG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myvpc.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

resource "aws_lb_target_group_attachment" "attach1" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.myec2-1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "attach2" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.myec2-2.id
  port             = 80
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.myalb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.tg.arn
    type             = "forward"
  }
}

output "loadbalancerdns" {
  value = aws_lb.myalb.dns_name
}





