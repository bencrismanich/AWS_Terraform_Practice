
# Create VPC
resource "aws_vpc" "wp-vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support = true


    tags = {
        Name = "wp-vpc"
    }
}
# Create public subnet
resource "aws_subnet" "public-subnet-1a" {
    vpc_id = "${aws_vpc.wp-vpc.vpc_id}"
    cidr_blocks = "10.0.0.0/24"
    availability_zone = "us-east-1a"

    tags = {
        Name = "Public Subnet"
    }

# Create private subnet
resource "aws_subnet" "private-subnet-1a" {
    vpc_id = "${aws_vpc.wp-vpc.vpc_id}"
    cidr_blocks = "10.0.1.0/24"
    availability_zone = "us-east-1a"

    tags = {
        Name = "Private Subnet - Application Servers"
    }
  
}