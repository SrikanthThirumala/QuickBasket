# /workspaces/AWS-Examples/main.tf

provider "aws" {
  region = "us-west-2"
  
}

module "network" {
  source = "./modules/network"
  
  # Passing the entire block of configurations at once
  config = var.network_config
}

module "compute" {
  source = "./modules/compute"
  
  # Passing the object from tfvars
  config = var.compute_config
  
  # Cross-Module Bridge: Passing outputs from network directly into compute
  vpc_id     = module.network.vpc_id
  FE_subnet_ids = module.network.FE_private_subnet_ids
  BE_subnet_ids = module.network.BE_private_subnet_ids
  FE_subnet_azs=module.network.FE_subnet_azs
  BE_subnet_azs=module.network.BE_subnet_azs

}
