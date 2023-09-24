resource "aws_security_group" "os" {
  name   = "${var.name}-sg"
  vpc_id = var.vpc_id

  # ingress {
  #   from_port       = 0
  #   to_port         = 0
  #
  #   protocol        = "-1"
  #
  #   security_groups = var.ingress_allowed_security_groups
  # }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "random_password" "os_master_user" {
  length = 20
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "os" {
  statement {
    effect = "Allow"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions   = ["es:*"]
    resources = ["arn:aws:es:${var.region}:${data.aws_caller_identity.current.account_id}:domain/${var.name}/*"]
  }
}


resource "aws_opensearch_domain" "default" {
  domain_name    = var.name
  engine_version = var.engine_version

  cluster_config {
    zone_awareness_enabled = true
    instance_count         = var.data_node_count
    dedicated_master_count = var.master_node_count
    dedicated_master_type  = var.master_node_instance_type
    warm_enabled           = false
    instance_type          = var.data_node_instance_type

    zone_awareness_config {
      availability_zone_count = length(var.subnet_ids)
    }
  }

  vpc_options {
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.os.id]
  }

  encrypt_at_rest {
    enabled = true
  }

  # access_policies = data.aws_iam_policy_document.os.json

  advanced_security_options {
    enabled                        = true
    internal_user_database_enabled = true
    master_user_options {
      master_user_name     = var.master_user_name
      master_user_password = random_password.os_master_user.result
    }
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  node_to_node_encryption {
    enabled = true
  }

  ebs_options {
    ebs_enabled = true
    volume_size = var.instance_volume_in_gb
  }

  tags = merge(var.common_tags,
    {
      Name = var.name
    }
  )
}

resource "aws_opensearch_domain_policy" "default" {
  domain_name     = aws_opensearch_domain.default.domain_name
  access_policies = data.aws_iam_policy_document.os.json
}
