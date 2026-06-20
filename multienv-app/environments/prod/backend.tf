terraform {
  backend "s3" {
    bucket       = "evnxc-tfstate-825475390189"
    key          = "environments/prod/terraform.tfstate"
    region       = "ap-southeast-1"
    encrypt      = true
    use_lockfile = true
  }
}