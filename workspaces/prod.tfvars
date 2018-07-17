region = "us-east-1"
vpc_name = "terraform-workshop"
cidr_block = "172.0.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
min_size = 1
max_size = 3
desired_capacity = 1
instance_type = "t2.micro"