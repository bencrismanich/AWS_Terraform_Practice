

resource "aws_security_group" "external-web-sg" {
    vpc_id = "${aws_vpc.wp-vpc.id}"
    description = "External Web Security Group"
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        "Name" = "External Web Security Group"
    }
  
}

resource "aws_security_group" "internal-web-sg" {
    vpc_id = "${aws_vpc.wp-vpc.id}"
    description = "Internal Web Security Group"
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        security_groups = ["${aws_security_group.external-web-sg.id}"]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        security_groups = ["${aws_security_group.external-web-sg.id}"]
    }
    tags = {
        "Name" = "Internal Web Security Group"
    }
  
}

resource "aws_security_group" "internal-data-sg" {
    vpc_id = "${aws_vpc.wp-vpc.id}"
    description = "Internal Data Security Group"
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        security_groups = ["${aws_security_group.internal-web-sg.id}"]
    }
    tags = {
        "Name" = "Internal Data Security Group"
    }
  
}


