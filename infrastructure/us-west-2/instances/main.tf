

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]  # Canonical owner ID for Ubuntu AMIs
}
resource "tls_private_key" "app_key" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "aws_key_pair" "app_key_pair" {
  key_name = "app-key-pair"
  public_key = tls_private_key.app_key.public_key_openssh
}




resource "aws_launch_configuration" "app_lc" {
  name_prefix = "app-"
  image_id = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name = aws_key_pair.app_key_pair.key_name
  iam_instance_profile = var.instance_profile_name
  security_groups = [ var.private_sg_id ]
    user_data = <<-USER_DATA
    #!/bin/bash
    sudo apt-get update -y
    sudo apt-get install nginx -y
    sudo systemctl start nginx
    sudo systemctl enable nginx
    sudo systemctl status nginx
    sudo apt install unzip -y
    sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    sudo unzip awscliv2.zip
    sudo ./aws/install
    sudo mv /var/www/html/index.nginx-debian.html /var/www/html/index.nginx-debian.html.bak
    sudo aws s3 cp s3://app-s3-bucket-drapp-west/ /var/www/html --recursive    
    USER_DATA
    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_autoscaling_group" "app_asg" {
  name                 = "app-asg"
  launch_configuration = aws_launch_configuration.app_lc.id
  min_size             = 1
  max_size             = 4
  desired_capacity     = 2
  health_check_type    = "EC2"
  health_check_grace_period = 300
  vpc_zone_identifier  = var.priv_subnet_ids
  

  

  tag {
    key                 = "Name"
    value               = "app_asg"
    propagate_at_launch = true
  }
}




resource "aws_lb" "app_lb" {
  name            = "app-lb"
  subnets         = var.public_subnet_ids
  security_groups = [var.lb_sg_id]
  internal           = false
  load_balancer_type = "application"
  tags = {
    Name = "app_lb"
  }
}

resource "aws_lb_target_group" "app_lb_tg" {
  name        = "app-lb-tg"
  port        = 80
  target_type = "instance"
  vpc_id      = var.vpc_id
  protocol    = "HTTP"
  health_check {
    enabled  = true
    interval = 10
    path     = "/"
    port     = 80
    protocol = "HTTP"
    matcher  = "200-299"
  }
  tags = {
    Name = "app_lb_tg"
  }
}

resource "aws_lb_listener" "app_lb_tg_listener_http" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_lb_tg.arn
  }
}

resource "aws_autoscaling_attachment" "app_asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.app_asg.name  
  lb_target_group_arn   = aws_lb_target_group.app_lb_tg.arn
}