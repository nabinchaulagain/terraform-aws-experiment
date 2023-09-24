variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "subnet_group_name" {
  type = string
}

variable "common_tags" {
  type = map(any)
}

variable "engine" {
  type    = string
  default = "aurora-postgresql"
}


variable "db_name" {
  type = string
}

variable "port" {
  type    = number
  default = 5432
}

variable "db_master_username" {
  type = string
}


variable "cluster_name" {
  type = string
}

variable "instance_class" {
  type    = string
  default = "db.t3.medium"
}

variable "ingress_allowed_security_groups" {
  type = list(string)
}

variable "is_publicly_accessible" {
  type    = bool
  default = false
}
