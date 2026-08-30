# /workspaces/AWS-Examples/modules/network/variable.tf

variable "config" {
  description = "A combined object for all network configurations"
  
  type = object({
    vpc_cidr       = string
    public_subnets = list(string)
    FE_private_subnets = list(string)
    BE_private_subnets = list(string)
    DB_private_subnets = list(string)
    az             = list(string)
    environment    = string
  })
}