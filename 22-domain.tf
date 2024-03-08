# get the name of LB
data "aws_lb" "lb" {
  arn  = var.lb_arn
  name = var.lb_name 
}

# get the name of domain name
data "aws_route53_zone" "public" {
  name         = var.public_dns_name
  private_zone = false
}

# get the zone id of hosted LB
data "aws_lb_hosted_zone_id" "main" {}

# create hostname for a domain in Route53
resource "aws_route53_record" "hostname" {
  count = "${var.domain == "yes" ? 1 : 0}"
  zone_id = data.aws_route53_zone.public.zone_id
  name    = "${var.dns_hostname}.${var.public_dns_name}"
  type    = "A"

  alias {
    name                   = data.aws_lb.lb.dns_name
    zone_id                = data.aws_lb_hosted_zone_id.main.id
    evaluate_target_health = true
  }
}

# Create Certificate
resource "aws_acm_certificate" "certificate" {
  count = "${var.domain == "yes" ? 1 : 0}"
  domain_name       = "${var.dns_hostname}.${var.public_dns_name}"
  validation_method = "DNS"
}

# Create AWS Route 53 Certificate Validation Record
resource "aws_route53_record" "hostname_validation" {
  for_each = {
    for dvo in aws_acm_certificate.certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.public.zone_id
}

# Create Certificate Validation
resource "aws_acm_certificate_validation" "certificate_validate" {
  count = "${var.domain == "yes" ? 1 : 0}"
  certificate_arn = aws_acm_certificate.certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.hostname_validation : record.fqdn]
}

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
