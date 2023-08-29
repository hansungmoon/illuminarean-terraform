##################### EC2 ###########################
# 시작 구성 생성
resource "aws_launch_configuration" "launch" {
  name_prefix = "illuminarean-launch"
  image_id = "ami-0c9c942bd7bf113a2"
  instance_type = "t3.micro"
  security_groups = [data.terraform_remote_state.vpc.outputs.private_sg_id]
  # associate_public_ip_address = true
  user_data = <<-EOF
        #!/bin/bash
        echo "Hello, World" > index.html
        nohup busybox httpd -f -p 80 &
        EOF
  lifecycle {
  create_before_destroy = true
  }
}

# Auto Scailing 그룹 생성
  resource "aws_autoscaling_group" "autogr" {
    name = "illuminarean-auto"
    launch_configuration = aws_launch_configuration.launch.name
    vpc_zone_identifier = [
      data.terraform_remote_state.vpc.outputs.public_subnets[0],
      data.terraform_remote_state.vpc.outputs.public_subnets[1]
    ]
    health_check_type = "ELB"
    target_group_arns = [aws_alb_target_group.user_target_group.arn]
    force_delete = true

    min_size = 6
    max_size = 10

    tag {
        key                 = "Name"
        value               = "illuminarean-auto"
        propagate_at_launch = true
  }
}

##################### ALB ###########################
resource "aws_alb" "user_lb" {
  name               = "illuminarean-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [data.terraform_remote_state.vpc.outputs.public_sg_id]
  subnets            = data.terraform_remote_state.vpc.outputs.public_subnets
}

resource "aws_alb_target_group" "user_target_group" {
  name        = "illuminarean-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
}

resource "aws_alb_listener" "user_http" {
  load_balancer_arn = aws_alb.user_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.user_target_group.id
    type             = "forward"
  }
}

##################### data ###########################

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "illuminarean-state-bucket"
    key    = "dev/vpc/terraform.tfstate"
    region = "ap-northeast-2"
  }
}