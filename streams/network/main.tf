provider "aws" {
  region = "${var.region}"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

terraform {
  backend "s3" {
    bucket = "demo-iac-workshop"
    key = "network"
    workspace_key_prefix = "environment"
    region = "us-east-1"
  }
}

module "network" {
  source = "../basic-networking"
  vpc_name = "${var.vpc_name}"
  cidr_block = "${var.cidr_block}"
  availability_zones = "${var.availability_zones}"
}