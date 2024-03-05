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
  zone_id = data.aws_route53_zone.public.zone_id
  name    = "${var.dns_hostname}.${var.public_dns_name}"
  type    = "A"

  alias {
    name                   = data.aws_lb.lb.dns_name
    zone_id                = data.aws_lb_hosted_zone_id.main.id
    evaluate_target_health = true
  }
}