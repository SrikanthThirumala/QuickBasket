# /workspaces/AWS-Examples/terraform.tfvars

network_config = {
  vpc_cidr       = "10.0.0.0/16"
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  FE_private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]
  BE_private_subnets = ["10.0.5.0/24", "10.0.6.0/24"]
  DB_private_subnets = ["10.0.7.0/24", "10.0.8.0/24"]
  az = ["us-west-2a","us-west-2b"]
  environment    = "production"
}

compute_config = {
  ami           = "ami-08b7b9fdd7a1edf3d"
  instance_type = "t3.micro"
  environment   = "production"
}













# sri_netf_ami_value = "ami-091124c3965bce679"
# sri_netf_vpc_cidr_value="10.0.0.0/16"
# sri_netf_type_value = "t3.micro"
# sri_netf_servername ="Frontend_server"
# sri_netf_region="us-west-1"


# # sri_netf_vpc_cidr_value = "10.0.0.0/16"