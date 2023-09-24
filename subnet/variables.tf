variable "vpc_id" {
  type = string
}

variable "subnet_count" {
  type = number
}

variable "vpc_cidr" {
  type = string
}

variable "common_tags" {
  type = map(any)
}

variable "igw_id" {
  type = string
}

variable "nat_gateway_count" {
  default = 1
  type    = number
}
