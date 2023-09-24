resource "aws_secretsmanager_secret" "default" {
  name                    = var.secret_name
  recovery_window_in_days = var.recovery_window_in_days

  tags = merge(var.common_tags,
    {
      Name = var.secret_name
    }
  )
}

resource "aws_secretsmanager_secret_version" "default" {
  secret_id     = aws_secretsmanager_secret.default.id
  secret_string = var.secret_string
}
