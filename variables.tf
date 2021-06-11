variable "aws_region" {
    default = "ca-central-1"
}
variable "vpc_cidr" {
    default = "10.0.0.0/24"
}
variable "subnet" {
    default = "10.0.0.0/28"
}
variable "ami_id" {
    default = "ami-0860c9429baba6ad2"
}
variable "instance_name" {
    default = "demo-vm-01"
}
variable "instance_type" {
    default = "t2.nano"
}
variable "instance_count" {
    default = "2"  
}
