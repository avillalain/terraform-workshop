resource "aws_elb" "elb" {
  name_prefix = "elb"
  subnets = ["${var.subnet_ids}"]
  security_groups = ["${aws_security_group.elb_http.id}"]
  listener {
    instance_port = 8080
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
    target = "HTTP:8080/"
  }
}