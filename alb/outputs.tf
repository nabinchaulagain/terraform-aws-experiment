output "tg_arn" {
  value = aws_lb_target_group.default.arn
}

output "lb_dns_name" {
  value = aws_lb.default.dns_name
}


output "lb_zone_id" {
  value = aws_lb.default.zone_id
}
