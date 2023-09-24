variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "private_key_generation_algorithm" {
  default = "RSA"
  type    = string
}

variable "key_name" {
  type = string
}

variable "instance_name" {
  type = string
}

variable "instance_type" {
  default = "t2.micro"
  type    = string
}

variable "common_tags" {
  type = map(any)
}

variable "instance_ami_name_pattern" {
  type    = string
  default = "al2023-ami-2023.*-x86_64"
}
