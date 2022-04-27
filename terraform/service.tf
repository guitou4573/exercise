# Setting up VM to host our service
# source: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_launch_configuration" "exercise_conf" {
  name          = "exercise-conf"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t2.nano"
  # user data installs node exporter on the instance, listening on port 9100 by default
  user_data = file("data/init.sh")
  security_groups = [aws_security_group.service_sg.id]
}

resource "aws_autoscaling_group" "exercise_asg" {
  name                      = "exercise-asg"
  max_size                  = 1
  min_size                  = 0
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 1
  force_delete              = true
  launch_configuration      = aws_launch_configuration.exercise_conf.name
  vpc_zone_identifier       = module.exercise_vpc.private_subnets
}

resource "aws_security_group" "service_sg" {
  name = "security_group_for_service"
  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = module.exercise_vpc.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "lb_sg" {
  name = "security_group_for_lb"
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
  
  vpc_id = module.exercise_vpc.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb" "service_lb" {
  name               = "service-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = module.exercise_vpc.private_subnets

  enable_deletion_protection = true

}

resource "aws_alb_target_group" "service_tg" {
  name     = "service-lb-tg"
  port     = 9100
  protocol = "HTTP"
  vpc_id   = module.exercise_vpc.vpc_id
}


resource "aws_lb_listener" "service_listener" {
  load_balancer_arn = aws_lb.service_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.service_tg.arn
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  autoscaling_group_name = aws_autoscaling_group.exercise_asg.id
  alb_target_group_arn   = aws_alb_target_group.service_tg.arn
}

output "elb-dns" {
  value = aws_lb.service_lb.dns_name
}