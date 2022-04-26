# Network interface for the VM hosting our service
resource "aws_network_interface" "vm_iface" {
  subnet_id   = module.exercise_vpc.private_subnets[0]
  private_ips = ["10.0.1.10"]
  security_groups = [aws_security_group.service_sg.id]

  tags = {
    Name = "primary_network_interface"
  }
}

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

resource "aws_instance" "vm_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  network_interface {
    network_interface_id = aws_network_interface.vm_iface.id
    device_index         = 0
  }

  # user data installs node exporter on the instance, listening on port 9100 by default
  user_data = file("data/init.sh")
}

resource "aws_security_group" "service_sg" {
  name = "security_group_for_service"
  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "elb_sg" {
  name = "security_group_for_elb"
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

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_elb" "service_elb" {
  name               = "service-elb"
  availability_zones = var.availability_zones
  security_groups    = [aws_security_group.elb_sg.id]

  listener {
    instance_port     = 9100
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:9100/"
    interval            = 30
  }

  instances                   = [aws_instance.vm_server.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400
}

output "elb-dns" {
  value = aws_elb.service_elb.dns_name
}