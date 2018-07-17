provider "aws" {
  region = "${var.region}"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

terraform {
  backend "s3" {
    bucket = "demo-iac-workshop"
    key = "sad"
    workspace_key_prefix = "environment"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "network" {
  workspace = "${terraform.workspace}"
  backend = "s3"
  config {
    bucket = "demo-iac-workshop"
    key = "network"
    workspace_key_prefix = "environment"
    region = "us-east-1"
  }
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

module "service" {
  source = "../service"
  ami_id = "${data.aws_ami.ec2_ami.id}"
  user_data = <<-EOF
              #!/bin/bash
              echo "Goodbye, World" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF
  vpc_id = "${data.terraform_remote_state.network.vpc_id}"
  subnet_ids = "${data.terraform_remote_state.network.public_subnet_ids}"
  min_size = "${var.min_size}"
  max_size = "${var.max_size}"
  desired_capacity = "${var.desired_capacity}"
  instance_type = "${var.instance_type}"
}

output "service" {
  value = "${module.service.url}"
}