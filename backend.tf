terraform {
  backend "s3" {
    region = "us-west-2"
    bucket = "quickbasket-state-file"
     key          = "quickbasket-prod/terraform.tfstate"
    use_lockfile = true
  }
}