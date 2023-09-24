variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "ingress_allowed_security_groups" {
  type = list(string)
}

variable "engine_version" {
  type    = string
  default = "OpenSearch_2.7"
}

variable "data_node_count" {
  type    = number
  default = 3
}

variable "master_node_count" {
  type    = number
  default = 3
}

variable "data_node_instance_type" {
  type    = string
  default = "t3.small.search"
}

variable "master_node_instance_type" {
  type    = string
  default = "t3.small.search"
}

variable "common_tags" {
  type = map(any)
}

variable "instance_volume_in_gb" {
  type    = number
  default = 10
}

variable "master_user_name"{
  type=string
}

variable "region"{
  type=string
}
