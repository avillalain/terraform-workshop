provider "aws" {
  region = "${var.region}"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
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

module "network" {
  source = "network"
  vpc_name = "${var.vpc_name}"
  cidr_block = "${var.cidr_block}"
  availability_zones = "${var.availability_zones}"
}

module "service" {
  source = "service"
  ami_id = "${data.aws_ami.ec2_ami.id}"
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF
  vpc_id = "${module.network.vpc_id}"
  subnet_ids = "${module.network.public_subnet_ids}"
  min_size = "${var.min_size}"
  max_size = "${var.max_size}"
  desired_capacity = "${var.desired_capacity}"
  instance_type = "${var.instance_type}"
}