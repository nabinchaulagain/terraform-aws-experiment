variable "vpc_id" {
  type = string
}

variable "tg_name" {
  type = string
}

variable "common_tags" {
  type = map(any)
}

variable "lb_name" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "certificate_arn" {
  type    = string
  default = null
}

variable "in_port" {
  type    = string
  default = "443"
}

variable "protocol" {
  type    = string
  default = "HTTPS"
}

variable "health_check_config" {
  description = "Map containing health check configuration options"
  type = object({
    healthy_threshold   = string
    interval            = string
    protocol            = string
    matcher             = string
    timeout             = string
    path                = string
    unhealthy_threshold = string
  })
}



variable "load_balancer_type" {
  type = string
  validation {
    condition     = var.load_balancer_type == "application" || var.load_balancer_type == "network"
    error_message = "load_balancer_type must be either application or network."
  }
}
