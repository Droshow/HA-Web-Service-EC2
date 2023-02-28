locals {

    project_name = "ec2-nginx-webservice"
    name_context = "${local.project_name}-${terraform.workspace}"
    name = "${local.project_name}-${terraform.workspace}"

    global_tag = {
        Deployment     = "Deployment Account 01"
    }

    project_tag = {
        Environment = terraform.workspace
        Project     = local.project_name
    }

    tags  = merge(local.global_tag,local.project_tag)

    region = "eu-central-1"

}
######################
#Simpler no module vpc
######################
# in case you do not want to use public repos


module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${local.name_context}-vpc"
  cidr = var.cidr

  azs             = ["eu-central-1a", "eu-central-1b",]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24",]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]
  enable_nat_gateway = true
  enable_vpn_gateway = false
  enable_dns_hostnames = true

  tags = local.tags

}

################
##security group
################
module "security" {
    source = "./modules/security"
    # vpc_id = aws_vpc.main.id if used no module vpc
    vpc_id = module.vpc.vpc_id

}

#########
#DATA AMI
#########
# TODO put a new Ami to it
data "aws_ami" "ec2_instance" {
  most_recent = true
  owners      = ["amazon"]

 filter {
    name   = "name"
    # values = ["amzn-ami-hvm*"]
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

############
#AutoScaling
############

resource "aws_launch_configuration" "launch_conf" {
  image_id      = data.aws_ami.ec2_instance.id
  instance_type = "t2.micro"
  security_groups = [module.security.EC2_sg]
  user_data =  filebase64("${path.module}/userdata.sh")
  iam_instance_profile = aws_iam_instance_profile.dev-resources-iam-profile.name
    root_block_device {
            volume_type = "gp2"
            volume_size = 10
            encrypted   = false
        }
     ebs_block_device {
            device_name = "/dev/sdf"
            volume_type = "gp2"
            volume_size = 5
            encrypted   = false
        }
}
resource "aws_autoscaling_group" "AS" {
  name = "${local.project_name} - autoscalling"
  vpc_zone_identifier = module.vpc.private_subnets
  desired_capacity   = 2
  max_size           = 2
  min_size           = 1
  depends_on 	     = [aws_lb.LoadBalancer]
  target_group_arns = [aws_lb_target_group.TG.arn]
  launch_configuration = aws_launch_configuration.launch_conf.name
}
#######################
#LoadBalancer
#######################
resource "aws_lb" "LoadBalancer" {
  name               = "${local.name_context}-LB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.security.alb_sg]
  subnets            = ["${module.vpc.public_subnets[0]}",
                    "${module.vpc.public_subnets[1]}"]
}
resource "aws_lb_target_group" "TG" {
  name     = "${local.name_context}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
  health_check {
    interval            = 70
    port                = 80
    path                = "/index.html"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 60
    protocol            = "HTTP"
    matcher             = "200,202"
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.LoadBalancer.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.TG.arn
  }
}


#######################
#IAM & instance profile
#######################
resource "aws_iam_instance_profile" "dev-resources-iam-profile" {
name = "ec2_profile"
role = aws_iam_role.dev-resources-iam-role.name
}

resource "aws_iam_role" "dev-resources-iam-role" {
name        = "dev-ssm-role"
description = "The role for the developer resources EC2"
assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": {
    "Effect": "Allow",
    "Principal": {"Service": "ec2.amazonaws.com"},
    "Action": "sts:AssumeRole"
                 }
}
EOF
}

resource "aws_iam_role_policy_attachment" "dev-resources-ssm-policy" {
role       = aws_iam_role.dev-resources-iam-role.name
policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
