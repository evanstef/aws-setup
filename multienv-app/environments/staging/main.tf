terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# variable "db_password" {
#   type        = string
#   sensitive   = true
#   description = "Password master RDS Postgres"
# } 

# tidak menggunakan variable lagi, karena sudah gua store di SSM Parameter Store
data "aws_ssm_parameter" "db_password" {
  name = "/app/db-password"
}

provider "aws" {
  region = "ap-southeast-1"

  # Tag default → otomatis nempel ke SEMUA resource di env ini (DRY)
  default_tags {
    tags = {
      CostCenter  = "Engineering"
      Owner       = "Evan"
      Environment = "staging"
    }
  }
}

# Bikin jaringan (VPC + subnet + IGW + NAT) buat env ini
module "network" {
  source      = "../../modules/network"
  environment = "staging"
}

module "eks" {
  source      = "../../modules/eks"
  environment = "staging"
  subnet_ids  = module.network.private_subnet_ids
}

module "app_stack" {
  source         = "../../modules/app-stack"
  environment    = "staging"
  db_password    = data.aws_ssm_parameter.db_password.value
  instance_type  = "t3.micro"
  app_domain     = "app-staging.evnxc.web.id"
  grafana_domain = "grafana-staging.evnxc.web.id"

  # Oper hasil module network → biar app masuk ke VPC ini
  vpc_id               = module.network.vpc_id
  public_subnet_id     = module.network.public_subnet_id
  db_subnet_group_name = module.network.db_subnet_group_name
}

module "asg" {
  source              = "../../modules/asg"
  environment         = "staging"
  target_group_vpc_id = module.network.vpc_id
  public_subnet_ids   = module.network.public_subnet_ids
  private_subnet_ids  = module.network.private_subnet_ids
  domain_name         = "app-staging.evnxc.web.id"
}

output "server_ip" {
  value = module.app_stack.server_ip
}

output "ssh_command" {
  value = module.app_stack.ssh_command
}

output "db_endpoint" {
  value = module.app_stack.db_endpoint
}