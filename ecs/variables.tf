variable "cluster_name" {
  type = string
}

variable "cpu_units" {
  type    = number
  default = 256

}
variable "memory_in_mb" {
  type    = number
  default = 512
}

variable "container_port" {
  type    = number
  default = 5000
}

variable "host_port" {
  type    = number
  default = 5000
}

variable "image_url" {
  type = string

}

variable "container_name" {
  type = string
}

variable "common_tags" {
  type = map(any)
}

variable "region" {
  type = string
}

variable "service_name" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "task_name" {
  type = string
}

variable "ecr_arn" {
  type = string
}

variable "lb_tg_arn"{
  type = string
}

variable "secrets_manager_arn"{
  type=string
}
