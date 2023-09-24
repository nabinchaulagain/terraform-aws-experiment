variable "secret_name" {
  type = string
}

variable "secret_string" {
  type = string
}

variable "common_tags" {
  type = map(any)
}

variable "recovery_window_in_days" {
  type    = number
  default = 0
}
