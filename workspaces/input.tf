variable "region" {
  default = "us-east-1"
}
variable "access_key" {}
variable "secret_key" {}
variable "cidr_block" {}
variable "vpc_name" {}
variable "availability_zones" {
  type = "list"
}
variable "min_size" {}
variable "max_size" {}
variable "desired_capacity" {}
variable "instance_type" {}