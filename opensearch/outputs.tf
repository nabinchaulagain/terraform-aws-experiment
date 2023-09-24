output "password" {
  value = aws_opensearch_domain.default.advanced_security_options[0].master_user_options[0].master_user_password
}

output "username" {
  value = aws_opensearch_domain.default.advanced_security_options[0].master_user_options[0].master_user_name
}

output "domain_url"{
  value = aws_opensearch_domain.default.endpoint
}
