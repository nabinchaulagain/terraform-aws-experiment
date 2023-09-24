variable "name" {
  type = string
}

variable "is_internal" {
  type    = bool
  default = true 
}

variable "subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "tg_name" {
  type = string
}

variable "in_port" {
  type = number
}

variable "protocol" {
  type    = string
  default = "TCP"
}

variable "common_tags" {
  type = map(any)
}


