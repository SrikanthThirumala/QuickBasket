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
  sri_rds_endpoint = module.database.sri_Rds_endpoint
  sri_rds_secret_name = module.database.sri_rds_secret_name
  sri-img-products-profile-name = module.iam.sri-img-products-profile-name
  sri-frontend-iam-profile-name=module.iam.sri-frontend-iam-profile-name
  sri-loki-logs-profile-name = module.iam.sri-loki-logs-profile-name
  sri_products_img_bucket_name = module.storage.sri-quickbasket-img-production-bucket-name
  sri_img_fetch_cloudfront_domain_name = module.cloudfront.quickbasket_img_fetch_cloudfront_domain_name
  
}


module "iam" {
  source = "./modules/iam"
}

module "storage" {
  source = "./modules/storage"
  
    environment = "production"
    quickbasket_img_fetch_cloudfront_arn = module.cloudfront.quickbasket_img_fetch_cloudfront_arn
  
}

module "database" {
  source = "./modules/database"
  DB_private_subnets_ids=module.network.DB_private_subnet_ids
  sri_quickbasket_RDS_SG_id = module.compute.sri_quickbasket_RDS_SG_id
}

module "cloudfront" {
  source = "./modules/Cloudfront"
  cldfrnt_config = {
    environment = "production"
    quickbasket_img_fetch_s3_regional_domain_name = module.storage.sri-quickbasket-img-production-bucket-regional-domain-name
    
  }
}
