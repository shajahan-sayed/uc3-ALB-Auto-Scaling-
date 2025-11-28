#creating vpc 

resource "aws_vpc" "vpc_alb" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "vpc-alb"
  }
}

resource "aws_subnet" "pub1" {
  vpc_id = aws_vpc.vpc_alb.id
  cidr_block = var.pub1_cidr
  availability_zone = var.availability_az1

  tags = {
    Name = "pub1"
  }
}

resource "aws_subnet" "pub2" {
  vpc_id = aws_vpc.vpc_alb.id
  cidr_block = var.pub2_cidr
  availability_zone = var.availability_az2
  
  tags = {
    Name = "pub2"
  }
}

resource "aws_subnet" "private1" {
  vpc_id = aws_vpc.vpc_alb.id
  cidr_block = var.private1_cidr
  availability_zone = var.availability_az1
  tags = {
    Name = "private1"
  }
}

resource "aws_subnet" "private2" {
  vpc_id = aws_vpc.vpc_alb.id
  cidr_block = var.private2_cidr
  availability_zone = var.availability_az2

  tags = {
    Name = "private1"
  }
}

resource "aws_internet_gateway" "igw_1" {
  vpc_id = aws_vpc.vpc_alb.id

  tags = {
    Name = "igw_1"
  }
}

resource "aws_route_table" "alb_route" {
  vpc_id = aws_vpc.vpc_alb.id

  tags = {
    Name = "alb_route"
  }
}

resource "aws_route" "alb_rt" {
  route_table_id = aws_route_table.alb_route.id
  gateway_id = aws_internet_gateway.igw_1.id
  destination_cidr_block = "0.0.0.0/0"

}

resource "aws_association_route_table" "alb_as1" {
   subnet_id = aws_subnet.pub2.id
   route_table_id = aws_route_table.alb_route.id

   tags = {
     Name = "alb_as"
    }
  }
  resource "aws_association_route_table" "alb_as2" {
   subnet_id = aws_subnet.pub2.id
   route_table_id = aws_route_table.alb_route.id

   tags = {
     Name = "alb_as"
    }
  }

resource "aws_security_group" "alb_sg" {
   vpc_id = aws_vpx.vpc_alb.id
   description = "allow http and ssh"

     ingress {
       description = "allow ssh"
       from_port = 80
       to_port = 80
       protocol = "tcp"
       cidr_blocks = ["0.0.0.0/0"]
      }
      egress {
       description = "allow all outbound rules"
       from_port = 0
       to_port = 0
       protocol = "-1"
       cidr_blocks = ["0.0.0.0/0"]
      }

      tags = {
        Name = "alb-sg"
       }
    }
resource "aws_security_group" "ec-sg" {
    vpc_id = aws_vpc.vp_alb.id

    ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      security_groups = [aws_security_group.alb_sg.id]
    }

    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "ec-sg"
    }
  }
resource "aws_security_group" "db-sg" {
    vpc_id = aws_vpc.vp_alb.id

    ingress {
      from_port = 3306
      to_port = 3306
      protocol = "tcp"
      security_groups = [aws_security_group.ec-sg.id]
    }

    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "db-sg"
    }
  }

#auto scaling group

#launch template

resource "aws_launch_template" "app" {
  image_id = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  block_device_mappings {
  device_name = "/dev/sda1"
  ebs {
      volume_size = 20
    }
  }



  user_data = base64encode(<<EOF
  #!/bin/bash
  # Update packages
  apt update -y
  apt install -y nginx

  # Enable and start NGINX
  systemctl enable nginx
  systemctl start nginx

  # Create welcome page
  cat <<EOT > /var/www/html/index.nginx-debian.html
  <h1>Welcome to Load balancer!</h1>
  <p>auto scale</p>
  <p>Served via Load Balancer</p>
 EOT
 EOF
  )

  network_interfaces {
    security_groups             = [aws_security_group.ec2_sg.id]
    associate_public_ip_address = true
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["077536343453"]  # Canonical official Ubuntu owner ID

  filter {
    name   = "lbs-auto"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}


resource "auto_scaling_group" "auto_lbs" {
  max_size = var.max_size
  min_size = var.min_size
  desired_capacity = var.desired_capacity
  vpc_zone_identifier = [ 
                          aws_subnet.pub1.id,
                          aws_subnet.pub2.id 
                        ]
  health_check_type   = "EC2"

  launch_template {
      id = aws_launch_template.app.id
      version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.app_tg.arn]
}
    
  
resource "aws_lb" "app_tg" {
  port = 80
  protocol = "HTTP" 
  vpc_id = aws_vpc.vpc_alb.id

  tags = {
    Name = "app_tg"
  }
}

resource "aws_lb_target_group" "app_tg" {
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  tags = {
    Name = "app_tg"
  }
}

resource "aws_lb_listener" "http" {
   load_balancer_arn = aws_lb.app_tg.id
   port = 80
   proctocol = "HTTP"
   
   default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

resource "aws_db_subnet_group" "mysql1" {
   subnet_ids = [
                aws_subnet.private1.id,
                aws_subnet.private2.id
               ]
   tags = {
     Name = "mysql1"
   }
}

resource "aws_db_instance" "mysql1" {
   engine = "mysql"
   instance_class = "db.t3.micro"
   allocated_storage       = 20
   db_name                 = "ecommerce"
   username                = var.db_username
   password                = var.db_password
   multi_az                = true
   vpc_security_group_ids  = [aws_security_group.db_sg.id]
   db_subnet_group_name    = aws_db_subnet_group.db_subnets.name
}
     
    

      
       
  
