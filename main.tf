terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~>3.0"
        }
    }
}

#configure the aws provider

provider "aws" {
    region = "us-east-2"
       
}

# Create a VPC

resource "aws_vpc" "myproj--aws_vpc" {
    cidr_block = var.cidr_block[0]

    tags = {
        Name = "Myproj-vpc"
    }

}

# Create Subnet (Public)

resource "aws_subnet" "Myproj-Subnet1" {
    vpc_id = aws_vpc.myproj--aws_vpc.id
    cidr_block = var.cidr_block[1]


    tags = {
        Name = "Myproj-Subnet1"
    }
}

# Create Internet Gateway

resource "aws_internet_gateway" "Myproj-InternetGW" {
    vpc_id = aws_vpc.myproj--aws_vpc.id

    tags = {
        Name = "Myproj-Internet Gateway"
    }

}

# Create Security Group

resource "aws_security_group" "Myproj-SG" {
  name = "Myproj SG"
  description = "to allow inbound and outbount traffics to Myproj" 
  vpc_id = aws_vpc.myproj--aws_vpc.id

  dynamic ingress {
      iterator = port
      for_each = var.ports
       content {
            from_port = port.value
            to_port = port.value
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
       }
      
  } 
 

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
      Name = "allow traffics"
  }

}

#Create route table and association

resource "aws_route_table" "Myproj-RouteTable" {
    vpc_id = aws_vpc.myproj--aws_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.Myproj-InternetGW.id   
    }

    tags = {
        Name = "Myproj-RouteTable"

    }

}

resource "aws_route_table_association" "MyProj-Association" {
    subnet_id = aws_subnet.Myproj-Subnet1.id
    route_table_id = aws_route_table.Myproj-RouteTable.id
  
}

#Create AWS EC2 Instance & Jenkins

#  locals {
#  user_data = <<-EOT
#  !/bin/bash
#  sudo yum install wget -y
#  sudo yum  update -y
#  sudo yum install fontconfig java-11-openjdk -y
#  sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
#  sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
#  sudo yum install jenkins -y
#  sudo chkconfig jenkins on
#  sudo systemctl enable jenkins
#  sudo systemctl start jenkins
#  sudo yum install httpd -y
#  sudo systemctl enable httpd
#  sudo systemctl start httpd
#  EOT
#}

resource "aws_instance" "Jenkins" {
  ami =  var.ami
  instance_type = var.instance_type
  key_name = var.key_name
  vpc_security_group_ids = [aws_security_group.Myproj-SG.id]
  subnet_id = aws_subnet.Myproj-Subnet1.id
  associate_public_ip_address = true
# user_data_base64       = base64encode(local.user_data)
  user_data = file("./InstallJenkins.sh")

  tags = {
    Name = "Jenkins-S"
  }
  
}
