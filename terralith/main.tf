variable "region" {
  default = "us-east-1"
}
variable "access_key" {}
variable "secret_key" {}
variable "cidr_block" {
  default = "10.0.0.0/16"
}
variable "vpc_name" {
  default = "terraform-workshop"
}
variable "max_size" {
  default = 2
}
variable "min_size" {
  default = 1
}
variable "desired_capacity" {
  default = 1
}
variable "instance_type" {
  default = "t2.micro"
}

provider "aws" {
  region = "${var.region}"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

resource "aws_vpc" "vpc" {
  cidr_block = "${var.cidr_block}"
  tags {
    Name = "${var.vpc_name}"
  }
}

resource "aws_subnet" "public" {
  cidr_block = "${cidrsubnet(var.cidr_block, 3, 0)}"
  availability_zone = "us-east-1a"
  vpc_id = "${aws_vpc.vpc.id}"
  tags {
    Name = "${format("%s-public-subnet", var.vpc_name)}"
  }
}

resource "aws_internet_gateway" "ig" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags {
    Name = "${format("%s-igw", var.vpc_name)}"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags {
    Name = "${format("%s-route-table", var.vpc_name)}"
  }
}

resource "aws_route" "public_route" {
  route_table_id = "${aws_route_table.public_route_table.id}"
  gateway_id = "${aws_internet_gateway.ig.id}"
  destination_cidr_block = "0.0.0.0/0"
  depends_on = ["aws_route_table.public_route_table"]
}

resource "aws_route_table_association" "public_route_table_association" {
  route_table_id = "${aws_route_table.public_route_table.id}"
  subnet_id = "${aws_subnet.public.id}"
}

resource "aws_subnet" "private" {
  cidr_block = "${cidrsubnet(var.cidr_block, 3, 1)}"
  availability_zone = "us-east-1a"
  vpc_id = "${aws_vpc.vpc.id}"
  tags {
    Name = "${format("%s-private-subnet", var.vpc_name)}"
  }
}

resource "aws_eip" "eip" {
  vpc = true
  tags {
    Name = "${format("%s-eip", var.vpc_name)}"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.eip.id}"
  subnet_id = "${aws_subnet.public.id}"
  tags {
    Name = "${format("%s-natgw", var.vpc_name)}"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags {
    Name = "${format("%s-private-route-table", var.vpc_name)}"
  }
}

resource "aws_route" "private_route" {
  route_table_id = "${aws_route_table.private_route_table.id}"
  nat_gateway_id = "${aws_nat_gateway.nat.id}"
  destination_cidr_block = "0.0.0.0/0"
  depends_on = ["aws_route_table.public_route_table"]
}

resource "aws_route_table_association" "private_route_table_association" {
  route_table_id = "${aws_route_table.private_route_table.id}"
  subnet_id = "${aws_subnet.private.id}"
}

data "aws_ami" "ec2_ami" {
  most_recent = true
  filter {
    name = "name"
    values = [
      "ubuntu/images/hvm-ssd/ubuntu-xenial*"]
  }
  filter {
    name = "architecture"
    values = [
      "x86_64"]
  }
  filter {
    name = "hypervisor"
    values = [
      "xen"]
  }
  filter {
    name = "root-device-type"
    values = [
      "ebs"
    ]
  }
  owners = [
    "099720109477"]
}

resource "aws_security_group" "instance_http" {
  vpc_id = "${aws_vpc.vpc.id}"
  ingress {
    from_port = 8080
    protocol = "tcp"
    to_port = 8080
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "elb_http" {
  vpc_id = "${aws_vpc.vpc.id}"
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_configuration" "alc" {
  image_id = "${data.aws_ami.ec2_ami.id}"
  instance_type = "${var.instance_type}"
  security_groups = ["${aws_security_group.instance_http.id}"]
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF
  name_prefix = "launch-config"
}

resource "aws_elb" "elb" {
  name_prefix = "elb"
  subnets = ["${aws_subnet.public.id}"]
  security_groups = ["${aws_security_group.elb_http.id}"]
  listener {
    instance_port = 8080
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
    target = "HTTP:8080/"
  }
}

resource "aws_autoscaling_group" "asg" {
  launch_configuration = "${aws_launch_configuration.alc.name}"
  max_size = "${var.max_size}"
  min_size = "${var.min_size}"
  desired_capacity = "${var.desired_capacity}"
  load_balancers = ["${aws_elb.elb.name}"]
  vpc_zone_identifier = ["${aws_subnet.public.id}"]
  health_check_type = "ELB"
}

output "service" {
  value =  "${aws_elb.elb.dns_name}"
}