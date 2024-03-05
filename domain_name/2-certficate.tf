# Create Certificate
resource "aws_acm_certificate" "certificate" {
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
  certificate_arn = aws_acm_certificate.certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.hostname_validation : record.fqdn]
}