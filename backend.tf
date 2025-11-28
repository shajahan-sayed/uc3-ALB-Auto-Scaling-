terraform {
  backend "s3" {
    bucket = "backend20775"
    key = "ec2/terraform.tfstate"
    region = "ap-southeast-2"
    dynamodb_table = "backend_2"
    encrypt = true
   }
}
