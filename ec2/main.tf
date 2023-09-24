resource "aws_security_group" "default" {
  name   = "${var.instance_name}-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags,
    {
      Name = "${var.instance_name}-sg"
    }
  )

}

resource "tls_private_key" "default" {
  algorithm = var.private_key_generation_algorithm
  rsa_bits  = 4096
}

resource "aws_key_pair" "default" {
  key_name   = var.key_name
  public_key = tls_private_key.default.public_key_openssh
}

data "aws_ami" "default" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = [var.instance_ami_name_pattern]
  }
}

resource "aws_instance" "default" {
  ami                    = data.aws_ami.default.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  key_name               = aws_key_pair.default.key_name
  vpc_security_group_ids = [aws_security_group.default.id]

  tags = merge(var.common_tags,
    {
      Name = var.instance_name
    }
  )
}


