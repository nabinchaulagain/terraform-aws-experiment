variable "cidr_block" {
  type = string
}

variable "vpc_igw_name" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "subnet_count" {
  type = number
}

variable "bastion_host_instance_name" {
  type = string
}

variable "bastion_host_key_pair_name" {
  type = string
}

variable "app_secret_name" {
  type = string
}

variable "db_subnet_group_name" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_master_username" {
  type = string
}

variable "db_cluster_name" {
  type = string
}

variable "backend_server_ecr_name" {
  type = string
}

variable "region" {
  type = string
}

variable "backend_server_service_name" {
  type = string
}

variable "backend_server_container_name" {
  type = string
}

variable "backend_server_cluster_name" {
  type = string
}

variable "backend_server_task_name" {
  type = string
}

variable "backend_server_tg_name" {
  type = string
}

variable "backend_server_lb_name" {
  type = string
}

variable "backend_domain_name" {
  type = string
}

variable "hosted_zone_name" {
  type = string
}

variable "opensearch_domain_name" {
  type = string
}

variable "primary_domain_name" {
  type = string
}

variable "opensearch_master_user_name" {
  type = string
}

variable "app_db_name" {
  type = string
}

variable "logstash_ecr_name" {
  type = string
}

variable "logstash_lb_name" {
  type = string
}

variable "logstash_lb_tg_name" {
  type = string
}

variable "logstash_listener_port" {
  type = number
}

variable "logstash_cluster_name" {
  type = string
}

variable "logstash_service_name" {
  type = string
}

variable "logstash_task_name" {
  type = string
}

variable "logstash_container_name" {
  type = string
}

variable "logstash_task_memory_in_mb" {
  type = number
}

variable "logstash_task_cpu_units" {
  type = number
}

variable "logstash_domain_name" {
  type = string
}
