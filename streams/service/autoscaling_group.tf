resource "aws_launch_configuration" "this" {
  image_id = "${var.ami_id}"
  instance_type = "${var.instance_type}"
  security_groups = ["${aws_security_group.instance_http.id}"]
  user_data = "${var.user_data}"
  name_prefix = "launch-config"
}

resource "aws_autoscaling_group" "this" {
  launch_configuration = "${aws_launch_configuration.this.name}"
  max_size = "${var.max_size}"
  min_size = "${var.min_size}"
  desired_capacity = "${var.desired_capacity}"
  load_balancers = ["${aws_elb.elb.name}"]
  vpc_zone_identifier = ["${var.subnet_ids}"]
  health_check_type = "ELB"
}