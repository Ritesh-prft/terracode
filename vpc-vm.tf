terraform {
  backend "s3" {
    bucket = "terraform-bucket-alex"
    key    = "terraform.tfstate"
    region = "ca-central-1"
  }
}
provider "aws" {
    region = "${var.aws_region}"
}

resource "aws_key_pair" "depl" {
  key_name   = "terra-keyi"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCL0RD8cxxzjtZgUZWtc9VlD8z6ZLlYGEjd7pmXxGn5qEYJZ6uEcLr10CTL8Q0f8gTrM7wTQX7UolseLfRiH61f8h0t0mZHbprIzd6eoauHPZd7OPo8rDOfK5nF9uJg3GBp3RqbRQYJGLFhJmbLb5wVs/XeMUFdr9klwOa0Wnodz72pGg71ZqNAfq4NI/YPZqkVlo8C6A8IPL5jTu+oeHFcHRux+4g0eEdL+p2m42UgRJmcgcf0/gvNn8rtKaYie9G5F2m4OYtAMcEzVc6g5atJu9MzBcUeyeC0t2iwZM7/vy/DSbkIGZBDA9WWWLx/EL74u4dJ5Dq5Ae1JgoyLLEfB terra-kp"
}

resource "aws_s3_bucket" "terra-demo-bucket-new" {
  bucket = "terra-demo-bucket-new"
  acl    = "private"

  tags = {
    Name        = "terra demo bucketaa"
    Environment = "Demo"
  }
}

resource "aws_vpc" "terra-demo-vpc" {
    cidr_block = "${var.vpc_cidr}" 
}
resource "aws_subnet" "web-subnet" {
    vpc_id = "${aws_vpc.terra-demo-vpc.id}"
    cidr_block = "${var.subnet}"
    availability_zone = "ca-central-1a"
    tags = {
      Name = "terra-demo-websubnet"
    }
}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.terra-demo-vpc.id

  tags = {
    Name = "terra-demo-igw"
  }
}
resource "aws_security_group" "allow_tls" {
    name        = "allow_tls"
    description = "Allow TLS inbound traffic"
    vpc_id      = "${aws_vpc.terra-demo-vpc.id}"
    ingress {
        description      = "HTTPS"
        from_port        = 443
        to_port          = 443
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
    }
    ingress {
        description      = "SSH"
        from_port        = 22
        to_port          = 22
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
    }

    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

  tags = {
        Name = "allow_tls"
    }
}

resource "aws_route_table" "terra-igw-route" {
  vpc_id = "${aws_vpc.terra-demo-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "example"
  }
}

resource "aws_eip" "lb" {
  instance = aws_instance.terra-demo-vm.id
  vpc      = true
  tags = {
    "Name" = "terra-demo-VM-pip"
  }
}

resource "aws_network_interface" "terra_demo_vm_nic" {
  subnet_id       = aws_subnet.web-subnet.id

  security_groups = ["${aws_security_group.allow_tls.id}"]
  tags = {
    Name = "terra-demo-nic"
  }

}

resource "aws_instance" "terra-demo-vm" {
    ami = "${var.ami_id}"
    instance_type = "${var.instance_type}"
    network_interface {
        network_interface_id = "${aws_network_interface.terra_demo_vm_nic.id}"
        device_index         = 0
      
    }
    depends_on = [aws_internet_gateway.gw]

    tags = {
        Name = "Demo instance"
    }
    
}

# module "ec2" {
#       source                      = "clouddrove/ec2/aws"
#       version                     = "0.14.0"
#       repository                  = "https://registry.terraform.io/modules/clouddrove/ec2/aws/0.14.0"
#       environment                 = "test"
#       label_order                 = ["name", "environment"]
#       instance_count              = 2
#       ami                         = "ami-08d658f84a6d84a80"
#       instance_type               = "t2.nano"
#       monitoring                  = false
#       tenancy                     = "default"
#       vpc_security_group_ids_list = [module.ssh.security_group_ids, module.http-https.security_group_ids]
#       subnet_ids                  = tolist(module.public_subnets.public_subnet_id)
#       assign_eip_address          = true
#       associate_public_ip_address = true
#       instance_profile_enabled    = true
#       iam_instance_profile        = module.iam-role.name
#       disk_size                   = 8
#       ebs_optimized               = false
#       ebs_volume_enabled          = true
#       ebs_volume_type             = "gp2"
#       ebs_volume_size             = 30
#       instance_tags               = { "snapshot" = true }
#       dns_zone_id                 = "Z1XJD7SSBKXLC1"
#       hostname                    = "ec2"
#     }