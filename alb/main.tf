locals {
  in_port = var.in_port
}

resource "aws_security_group" "lb" {
  name   = "${var.lb_name}-sg"
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
      Name = "${var.lb_name}-sg"
    }
  )

}

resource "aws_lb" "default" {
  name               = var.lb_name
  load_balancer_type = var.load_balancer_type
  security_groups    = [aws_security_group.lb.id]
  subnets            = var.subnet_ids

  tags = merge(var.common_tags,
    {
      Name = var.lb_name
    }
  )
}

resource "aws_lb_target_group" "default" {
  name_prefix = var.tg_name
  port        = local.in_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    healthy_threshold   = var.health_check_config["healthy_threshold"]
    interval            = var.health_check_config["interval"]
    protocol            = var.health_check_config["protocol"]
    matcher             = var.health_check_config["matcher"]
    timeout             = var.health_check_config["timeout"]
    path                = var.health_check_config["path"]
    unhealthy_threshold = var.health_check_config["unhealthy_threshold"]

    }

  lifecycle {
    create_before_destroy = true
  }


  tags = merge({
    Name = var.tg_name,
  }, var.common_tags)
}


resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.default.arn
  port              = local.in_port # This doesnt really matter as we have ports for indvidual targets defined.
  protocol          = var.protocol
  ssl_policy        = var.protocol == "HTTPS" ? "ELBSecurityPolicy-2016-08" : null
  certificate_arn   = var.protocol == "HTTPS" ? var.certificate_arn : null

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.default.arn
  }
}

