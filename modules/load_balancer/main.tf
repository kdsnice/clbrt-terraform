resource "aws_elb" "clbrt" {
  name    = "clbrt-terraform-elb"
  subnets = [for s in var.subnets : s.id]

  listener {
    instance_port     = 8000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    target              = "HTTP:8000/"
    interval            = 30
  }

  cross_zone_load_balancing = true
  security_groups           = var.security_groups
}