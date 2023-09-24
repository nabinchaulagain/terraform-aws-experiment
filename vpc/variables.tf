variable "cidr_block" {
  type = string
}

variable "vpc_tags" {
  type = map(any)
}

variable "igw_tags" {
  type = map(any)
}
