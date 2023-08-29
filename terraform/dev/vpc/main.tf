################################ VPC ####################################
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "illuminarean-vpc"
  cidr = "172.5.0.0/16"

  azs = [
    "ap-northeast-2a",
    "ap-northeast-2c"
  ]
  private_subnets = [
    "172.5.101.0/24",
    "172.5.102.0/24"
  ]
  public_subnets = [
    "172.5.1.0/24",
    "172.5.2.0/24"
  ]

  # Single NAT Gateway
  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

################################ 보안그룹 ####################################

resource "aws_security_group" "public_sg" {

  name = "illuminarean_public"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
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
    protocol    = "all"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "illuminarean-pub"
  }
}

resource "aws_security_group" "private_sg" {

  name = "illuminarean_private"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "all"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "illuminarean-pri"
  }
}
