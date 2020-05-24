resource "aws_lb" "wp-lb" {
    name = "WPLoadBalancer"
    internal = false
    load_balancer_type = "application"
    security_groups = ["${aws_security_group.external-web-sg.id}"]
    subnets = ["${aws_subnet.public-global-1a.id}", "${aws_subnet.public-global-1b.id}"]

    #listener TCP port 80 (HTTP)
    #subnets - public zone A and B
    #security group - externalweb
    #target group (name=WPServers)
}

resource "aws_lb_target_group" "wp-lb-tg" {
    name = "WPLoadBalancer-tg"
    port = 80
    protocol = "HTTP"
    vpc_id = "${aws_vpc.wp-vpc.id}"
    target_type = "instance"
}

resource "aws_lb_listener" "wp-lb-list" {
    load_balancer_arn = "${aws_lb.wp-lb.arn}"
    port = 80
    protocol = "HTTP"
    default_action {
        target_group_arn = "${aws_lb_target_group.wp-lb-tg.arn}"
        type = "forward"
    }
}

resource "aws_lb_target_group_attachment" "wp-lb-attach-80" {
  target_group_arn          = "${aws_lb_target_group.wp-lb-tg.arn}"
  target_id                 = "${aws_instance.instance-wc-1.id}"
  port                      = 80
}

resource "aws_lb_target_group_attachment" "wp-lb-attach-22" {
  target_group_arn          = "${aws_lb_target_group.wp-lb-tg.arn}"
  target_id                 = "${aws_instance.instance-wc-1.id}"
  port                      = 22
}

resource "aws_instance" "instance-wc-1" {
    ami                     = "ami-0323c3dd2da7fb37d"
    instance_type           = "t2.micro"
    subnet_id               = "${aws_subnet.private-app-1a.id}"
    iam_instance_profile    = "SSMRole"
    security_groups         = ["${aws_security_group.internal-web-sg.id}"]
    key_name                = "key1"
    tags = {
        Name = "WebServer-1"
    }
}

##### LAUNCH DB INSTANCE #####

resource "aws_db_instance" "wp-instance" {
  allocated_storage       = 20
  storage_type            = "gp2"
  engine                  = "mysql"
  instance_class          = "db.t2.micro"
  db_subnet_group_name    = "${aws_db_subnet_group.data-tier-subnets.name}"
  vpc_security_group_ids  = ["${aws_security_group.internal-data-sg.id}"]
  identifier              = "wp-instance"
  multi_az                = true
  name                    = "WPInstance"
  username                = "${var.username}"
  password                = "${var.password}"
  #snapshot_identifier     = "${data.aws_db_snapshot.latest_prod_snapshot.id}"
  skip_final_snapshot     = true
  # lifecycle {
  #   ignore_changes = ["snapshot_identifier"]
  # }
  tags = {
        Name = "WPInstance"
    }
  
}

# data "aws_db_snapshot" "latest_prod_snapshot" {
#   db_instance_identifier = "${aws_db_instance.wp-instance.id}"
#   most_recent            = true
# }