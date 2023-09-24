resource "aws_security_group" "lb" {
  name   = "${var.name}-sg"
  vpc_id = var.vpc_id

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

  tags = merge(var.common_tags,
    {
      Name = "${var.name}-sg"
    }
  )
}

resource "aws_lb" "main" {
  name               = var.name
  internal           = var.is_internal
  load_balancer_type = "network"
  subnets            = var.subnet_ids
  security_groups    = [aws_security_group.lb.id]

  tags = merge(var.common_tags,
    {
      Name = var.name
    }
  )
}

resource "aws_lb_target_group" "main" {
  name_prefix = var.tg_name
  port        = var.in_port
  protocol    = var.protocol
  target_type = "ip"
  vpc_id      = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }


  tags = merge({
    Name = var.tg_name,
  }, var.common_tags)
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = var.in_port # This doesnt really matter as we have ports for indvidual targets defined.
  protocol          = var.protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}



