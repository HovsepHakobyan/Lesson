rovider "aws" {
  region     = "eu-central-1"
 

}

resource "aws_vpc" "game-project" {
  cidr_block           = var.vpc_cider
  enable_dns_hostnames = true

  tags = {
    Name = "game-project"
  }

}


resource "aws_internet_gateway" "vpc_game-project" {
  vpc_id = aws_vpc.game-project.id

  tags = {
    Name = "igw-vpc-game-project"
  }

}


resource "aws_subnet" "public_A" {
  vpc_id            = aws_vpc.game-project.id
  cidr_block        = var.public-A
  availability_zone = "eu-central-1a"

  tags = {
    Name = "public_A"
  }

}

resource "aws_subnet" "public_B" {
  vpc_id            = aws_vpc.game-project.id
  cidr_block        = var.public-B
  availability_zone = "eu-central-1b"

  tags = {
    Name = "public_B"
  }

}


resource "aws_route_table" "public_Route" {
  vpc_id = aws_vpc.game-project.id

  route = []

  tags = {
    Name = "public-rout"
  }

}

resource "aws_route_table_association" "public_A-associate" {
  subnet_id      = aws_subnet.public_A.id
  route_table_id = aws_internet_gateway.vpc_game-project.id

}

resource "aws_route_table_association" "public_B-associate" {
  subnet_id      = aws_subnet.public_B.id
  route_table_id = aws_internet_gateway.vpc_game-project.id

}


resource "aws_subnet" "private_A" {
  vpc_id            = aws_vpc.game-project.id
  cidr_block        = var.private-A
  availability_zone = "eu-central-1a"

  tags = {
    Name = "private_A"
  }

}


resource "aws_subnet" "private_B" {
  vpc_id            = aws_vpc.game-project.id
  cidr_block        = var.private-B
  availability_zone = "eu-central-1b"

  tags = {
    Name = "private_B"
  }

}


resource "aws_nat_gateway" "public_A-nat" {
  subnet_id = aws_subnet.public_A.id

  tags = {
    Name = "public_A NAT"
  }


  depends_on = [aws_internet_gateway.vpc_game-project]
}

resource "aws_nat_gateway" "public_B-nat" {
  subnet_id = aws_subnet.public_B.id

  tags = {
    Name = "public_B NAT"
  }

}



data "aws_availability_zones" "available" {}
data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_security_group" "game-secgroup" {
  name = "Dyinamic Security Group"

  dynamic "ingress" {
    for_each = ["80", "443",]
    content {
      from_port  = ingress.value
      to_port    = ingress.value
      protocol   = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
 egress {
  from_port  = 0
  to_port    = 0
  protocol   = "-1"
  cidr_blocks = ["0.0.0.0/0"]
 }

tags = {
  Name = "Dynamic SecurityGroup"

 }
    }
  

resource "aws_launch_configuration" "game-project-LC" {
  name            = "game-project-LC"
  image_id        = data.aws_ami.latest_amazon_linux.id
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.game-secgroup.id]

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_autoscaling_group" "game-ASG" {
  name                 = "game-project-ASG"
  launch_configuration = aws_launch_configuration.game-project-LC.name
  min_size             = 2
  max_size             = 2
  min_elb_capacity     = 2
  vpc_zone_identifier  = [aws_subnet.public_A.id, aws_subnet.public_B.id]
  health_check_type    = "ELB"
  load_balancers       = [aws_elb.game-ELB.name]

  tags = [
    {
      key                 = "Name"
      value               = "game-ASG"
      propagate_at_launch = true

    }
    

  ]
  
}



resource "aws_elb" "game-ELB" {
  name               = "game-ELB"
  availability_zones = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  security_groups    = [aws_security_group.game-secgroup.id]
  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = 80
    instance_protocol = "http"
  }
  health_check {
    healthy_threshold  = 2
    unhealthy_threshold = 2
    timeout            = 3
    target             = "HTTP:80/"
    interval           = 10
  }
  tags = {
    Name = "game-elb"
  }
}