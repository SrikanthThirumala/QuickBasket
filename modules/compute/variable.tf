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