variable "sri_private_subnets_ids" {
  description = " private subnet ids values to lb module from network module"
  type = list(string)
}

variable "sri_public_subnets_ids" {
  description = " public subnet ids values to lb module from network module"
  type = list(string)
}

variable "sri_quickbasket_Frontend_ALB_SG_id" {
  description = "sri_quickbasket_Frontend_ALB_SG_id value from compute module"
  type = string
}

variable "sri_quickbasket_Backend_ALB_SG_id" {
  description = "sri_quickbasket_Backend_ALB_SG_id value from compute module"
  type = string
}

variable "sri_quickbasket_front_end_server_id" {
  description = "frontend server id value from compute module"
  type = string
}


variable "sri_quickbasket_back_end_server_id" {
  description = "backend server id value from compute module"
  type = string
}

variable "sri_vpc_id" {
  description = "vpc_id value from network module"
  type = string
}