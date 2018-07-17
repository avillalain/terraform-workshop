region = "us-east-1"
vpc_name = "terraform-workshop"
cidr_block = "10.0.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b"]
min_size = 1
max_size = 2
desired_capacity = 1
instance_type = "t2.micro"