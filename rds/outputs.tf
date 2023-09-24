output "hostname" {
  value = aws_rds_cluster.default.endpoint
}

output "password" {
  value     = aws_rds_cluster.default.master_password
  sensitive = true
}

output "username" {
  value     = aws_rds_cluster.default.master_username
  sensitive = true
}

output "port" {
  value = aws_rds_cluster.default.port
}

