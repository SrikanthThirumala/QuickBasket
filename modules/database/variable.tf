variable "DB_private_subnets_ids" {
  description = "db private subnet ids values to database module from network module"
  type = list(string)
}

variable "sri_quickbasket_RDS_SG_id" {
  description = "rds sg value to database module from network module"
  type = string
}