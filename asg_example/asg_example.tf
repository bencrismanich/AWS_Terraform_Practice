provider "aws" {
  profile = "default"
  region = "us-east-1"
}
resource "aws_launch_template" "asg_example" {
  name          = "asg_example"
  image_id      = "ami-2757f631"
  instance_type = "t2.micro"
}

resource "aws_autoscaling_group" "bc-asg-sandpit" {
name = "bc-asg-sandpit"
availability_zones = ["us-east-1a"]
  desired_capacity   = 1
  max_size           = 1
  min_size           = 1

  launch_template {
      id = "${aws_launch_template.asg_example.id}"
      version = "$Latest"
  }
}