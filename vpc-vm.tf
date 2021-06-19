terraform {
  backend "s3" {
    bucket = "terraform-bucket-terra"
    key    = "terraform.tfstate"
    region = "ca-central-1"
  }
}
provider "aws" {
  region = "ap-south-1"

  assume_role {
    role_arn = "arn:aws:iam::XXXXX:role/XXXXXX"
  }
}


resource "aws_vpc" "terra-demo-vpc-role" {
    cidr_block = "192.168.0.0/16" 
}
resource "aws_subnet" "web-subnet-role" {
    vpc_id = "${aws_vpc.terra-demo-vpc.id}"
    cidr_block = "192.168.1.0/24"
    availability_zone = "ca-central-1a"
    tags = {
      Name = "terra-websubnet"
    }
}
