# Create VPC with 65,534 available addresses
resource "aws_vpc" "wp-vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = {
        Name = "wp-vpc"
    }
}

##############################################################
#################### SUBNETS - us-east-1a ####################
##############################################################

# Carve up /16 to create public subnet with /24
resource "aws_subnet" "public-global-1a" {
    vpc_id = "${aws_vpc.wp-vpc.id}"
    cidr_block = "10.0.0.0/24"
    availability_zone = "us-east-1a"

    tags = {
        Name = "Public-AZ-A"
    }
}

# /24 subnet for web applications
resource "aws_subnet" "private-app-1a" {
    vpc_id = "${aws_vpc.wp-vpc.id}"
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"

    tags = {
        Name = "App-AZ-A"
    }
}

# /24 subnet for database applications
resource "aws_subnet" "private-data-1a" {
    vpc_id = "${aws_vpc.wp-vpc.id}"
    cidr_block = "10.0.2.0/24"
    availability_zone = "us-east-1a"
    tags = {
        Name = "Data-AZ-A"
    }
}

##############################################################
#################### SUBNETS - us-east-1b ####################
##############################################################

# Carve up /16 to create public subnet with /24
resource "aws_subnet" "public-global-1b" {
    vpc_id = "${aws_vpc.wp-vpc.id}"
    cidr_block = "10.0.3.0/24"
    availability_zone = "us-east-1b"

    tags = {
        Name = "Public-AZ-B"
    }
}

# /24 subnet for web applications
resource "aws_subnet" "private-app-1b" {
    vpc_id = "${aws_vpc.wp-vpc.id}"
    cidr_block = "10.0.4.0/24"
    availability_zone = "us-east-1b"

    tags = {
        Name = "App-AZ-B"
    }
}

# /24 subnet for database applications
resource "aws_subnet" "private-data-1b" {
    vpc_id = "${aws_vpc.wp-vpc.id}"
    cidr_block = "10.0.5.0/24"
    availability_zone = "us-east-1b"
    tags = {
        Name = "Data-AZ-B"
    }
}

##### SUBNET GROUP FOR DATABASE #####

resource "aws_db_subnet_group" "data-tier-subnets" {
  name       = "data-tier-subnets"
  subnet_ids = ["${aws_subnet.private-data-1a.id}", "${aws_subnet.private-data-1b.id}"]

  tags = {
    Name = "Data Tier Subnets"
  }
}

##############################################################
################### EIP resource #################
##############################################################

# Create Elastic IP address and associate with NAT Gateway - 1a
resource "aws_eip" "nat-eip-1a" {
    vpc = true
    tags = {
        Name = "elastic-ip-1a"
    }
}

# Create Elastic IP address and associate with NAT Gateway - 1b

resource "aws_eip" "nat-eip-1b" {
    vpc = true
    tags = {
        Name = "elastic-ip-1b"
    }
}

##############################################################
################### EIP associations #################
##############################################################

resource "aws_eip_association" "nat-eip-association-1a" {
    instance_id = "${aws_nat_gateway.nat-gateway-1a.id}"
    allocation_id = "${aws_eip.nat-eip-1a.id}"
}

resource "aws_eip_association" "nat-eip-association-1b" {
    instance_id = "${aws_nat_gateway.nat-gateway-1b.id}"
    allocation_id = "${aws_eip.nat-eip-1b.id}"
}

# Create NAT Gateway with Elastic IP address - 1a
resource "aws_nat_gateway" "nat-gateway-1a" {
    allocation_id = "${aws_eip.nat-eip-1a.id}"
    subnet_id = "${aws_subnet.public-global-1a.id}"
    tags = {
        Name = "NAT Gateway 1a"
    }
}

# Create NAT Gateway with Elastic IP address - 1b
resource "aws_nat_gateway" "nat-gateway-1b" {
    allocation_id = "${aws_eip.nat-eip-1b.id}"
    subnet_id = "${aws_subnet.public-global-1b.id}"
    tags = {
        Name = "NAT Gateway 1b"
    }
}

# Create Internet Gateway
resource "aws_internet_gateway" "internet-gateway" {
    vpc_id = "${aws_vpc.wp-vpc.id}"
    tags = {
        Name = "Internet Gateway"
    }
}


##############################################################
######################## Route tables ########################
##############################################################

resource "aws_route_table" "route-table-public-a" {
    vpc_id = "${aws_vpc.wp-vpc.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.internet-gateway.id}"
    }
    tags = {
        Name = "Route Table Public - A"
    }
}

resource "aws_route_table" "route-table-public-b" {
    vpc_id = "${aws_vpc.wp-vpc.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.internet-gateway.id}"
    }
    tags = {
        Name = "Route Table Public - B"
    }
}

resource "aws_route_table" "route-table-private-b" {
    vpc_id = "${aws_vpc.wp-vpc.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_nat_gateway.nat-gateway-1b.id}"
    }
    tags = {
        Name = "Route Table Private - B"
    }
}

resource "aws_route_table" "route-table-private-a" {
    vpc_id = "${aws_vpc.wp-vpc.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_nat_gateway.nat-gateway-1a.id}"
    }
    tags = {
        Name = "Route Table Private - A"
    }
}

##############################################################
################### Route table associations #################
##############################################################

resource "aws_route_table_association" "route-assoc-public-a" {
  subnet_id      = "${aws_subnet.public-global-1a.id}"
  route_table_id = "${aws_route_table.route-table-public-a.id}"
}

resource "aws_route_table_association" "route-assoc-public-b" {
  subnet_id      = "${aws_subnet.public-global-1b.id}"
  route_table_id = "${aws_route_table.route-table-public-b.id}"
}

resource "aws_route_table_association" "route-assoc-private-a-1" {
  subnet_id      = "${aws_subnet.private-app-1a.id}"
  route_table_id = "${aws_route_table.route-table-private-a.id}"
}

resource "aws_route_table_association" "route-assoc-private-a-2" {
  subnet_id      = "${aws_subnet.private-data-1a.id}"
  route_table_id = "${aws_route_table.route-table-private-a.id}"
}
resource "aws_route_table_association" "route-assoc-private-b-1" {
  subnet_id      = "${aws_subnet.private-data-1b.id}"
  route_table_id = "${aws_route_table.route-table-private-b.id}"
}

resource "aws_route_table_association" "route-assoc-private-b-2" {
  subnet_id      = "${aws_subnet.private-app-1b.id}"
  route_table_id = "${aws_route_table.route-table-private-b.id}"
}