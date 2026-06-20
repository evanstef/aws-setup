terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "db_password" {
  type        = string
  sensitive   = true
  description = "Password master RDS Postgres"
}

provider "aws" {
  region = "ap-southeast-1"
}

# Bikin jaringan (VPC + subnet + IGW + NAT) buat env ini
module "network" {
  source      = "../../modules/network"
  environment = "prod"
}

module "app_stack" {
  source         = "../../modules/app-stack"
  environment    = "prod"
  db_password    = var.db_password
  instance_type  = "t3.medium"
  app_domain     = "app.evnxc.web.id"
  grafana_domain = "grafana.evnxc.web.id"

  # Oper hasil module network → biar app masuk ke VPC ini
  vpc_id               = module.network.vpc_id
  public_subnet_id     = module.network.public_subnet_id
  db_subnet_group_name = module.network.db_subnet_group_name
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