variable "ami_id" {}
variable "user_data" {}
variable "vpc_id" {}
variable "subnet_ids" {
  type = "list"
}
variable "min_size" {}
variable "max_size" {}
variable "desired_capacity" {}
variable "instance_type" {}