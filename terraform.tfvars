aws_region          = "ap-southeast-2"
instance_type   = "t3.micro"

desired_capacity = 2
min_size         = 1
max_size         = 4

vpc_cidr = "10.0.0.0/16"
pub1_cidr = "10.0.1.0/24"
pub2_cidr = "10.0.2.0/24"
private1_cidr = "10.0.3.0/24"
private2_cidr = "10.0.4.0/24"

availability_az1 = "ap-southeast-2a"
availability_az1 = "ap-southeast-2b"

db_username = "admin"
db_password = "shaju123"
