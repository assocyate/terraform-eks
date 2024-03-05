# get the data from LB target group
data "aws_lb_target_group" "target_group" {
  arn  = var.lb_tg_arn
  name = var.lb_tg_name
}

# create TLS listener for https
resource "aws_lb_listener" "hostname_tls" {
  load_balancer_arn = data.aws_lb.lb.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.certificate.arn
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action {
    type             = "forward"
    target_group_arn = data.aws_lb_target_group.target_group.arn
  }

  depends_on = [aws_acm_certificate_validation.certificate_validate]
}

