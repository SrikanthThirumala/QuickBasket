# /workspaces/AWS-Examples/modules/compute/variable.tf

variable "config" {
  description = "A combined object for all Compute configurations"
  
  type = object({
    ami      = string
    instance_type = string
    environment    = string
  })
}

# New variables to catch the network outputs
variable "vpc_id" {
  description = "The VPC ID passed from the network module"
  type        = string
}

variable "FE_subnet_ids" {
  description = "The Frontend private subnets passed from the network module"
  type        = list(string)
}

variable "BE_subnet_ids" {
  description = "The Backend private subnets passed from the network module"
  type        = list(string)
}

variable "FE_subnet_azs" {
  description = "The az values passed from the network module"
  type        = list(string)
}

variable "BE_subnet_azs" {
  description = "The az values passed from the network module"
  type        = list(string)
}

variable "sri_rds_endpoint" {
  description = "The rds endpoint passed from the database module"
  type        = string
}

variable "sri_rds_secret_name" {
  description = "The rds secret name passed from the database module"
  type        = string
}

variable "sri-loki-logs-profile-name" {
  description = "sri-img-products role name value from iam module "
  type = string
}

variable "sri-img-products-profile-name" {
  description = "sri-loki-logs-profile name value from iam module"
  type = string
}

variable "sri_img_fetch_cloudfront_domain_name" {
  description = "quickbasket_img_fetch_cloudfront_domain_name value"
  type = string
}

variable "sri_products_img_bucket_name" {
  description = "sri_products_img_bucket_name value"
  type = string
}
