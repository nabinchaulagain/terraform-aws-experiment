output "tg_arn" {
  value = aws_lb_target_group.main.arn
}

output "lb_dns_name" {
  value = aws_lb.main.dns_name
}

output "lb_zone_id" {
  value = aws_lb.main.zone_id
}
