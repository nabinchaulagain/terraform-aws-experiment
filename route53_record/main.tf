data "aws_route53_zone" "main" {
  name         = var.zone_name
  private_zone = false
}

resource "aws_route53_record" "main" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.record_name
  type    = "A"

  alias {
    name                   = var.domain_name
    zone_id                = var.zone_id
    evaluate_target_health = true
  }
}

