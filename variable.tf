variable "aws_region" {
  type    = string
  default = "ap-southeast-2"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "desired_capacity" {
  type    = number
  default = 2
}

variable "min_size" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 4
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "vpc_cidr" {
  type = string
  default = "10.0.0.0/16"
}
variable "pub1_cidr" {
  type = string
  default = "10.0.1.0/24"
}
variable "pub2_cidr" {
  type = string
  default = "10.0.2.0/24"
}
variable "private1_cidr" {
  type = string
  default = "10.0.3.0/24"
}
variable "private2_cidr" {
  type = string
  default = "10.0.4.0/24"
}
variable "availability_az1" {
  type = string
  default = "ap-southeast-2a"
}
variable "availability_az2" {
  type = string
  default = "ap-southeast-2b"
}

