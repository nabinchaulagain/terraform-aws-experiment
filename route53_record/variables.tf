variable "zone_name" {
  type = string
}

variable "primary_domain_name" {
  type = string
}

variable "common_tags" {
  type = map(any)
}

variable "domain_name" {
  type = string

}
variable "zone_id" {
  type = string
}

variable "record_name"{
  type=string
}
