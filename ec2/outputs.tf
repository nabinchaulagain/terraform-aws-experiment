output "private_key" {
  value = tls_private_key.default.private_key_pem

}

output "security_group_id" {
  value = aws_security_group.default.id
}
