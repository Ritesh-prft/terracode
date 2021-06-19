/* terraform {
  backend "s3" {
    bucket = "jenkins-bucket-tfstate"
    key    = "terraform.tfstate"
    region = "ap-south-1"
  }
} */
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "jenkins-bucket-tfstate"
    key    = "terraform.tfstate"
    region = "ap-south-1"
  }
}


provider "aws" {
  region = "ap-south-1"
  assume_role {
    role_arn     = "arn:aws:iam::466515034134:role/jenkins-deploy"
    session_name = "jenkins-Session"
  }

}
/* provider "aws" {
  region = "ap-south-1"
  shared_credentials_file = "$HOME/.aws/credentials"
  profile = "aws_profile"
}
 */

resource "aws_vpc" "terra-demo-vpc-role" {
    cidr_block = "192.168.0.0/16" 
}
resource "aws_subnet" "web-subnet-role" {
    vpc_id = "${aws_vpc.terra-demo-vpc-role.id}"
    cidr_block = "192.168.1.0/24"
    availability_zone = "ca-central-1a"
    tags = {
      Name = "terra-websubnet"
    }
}
