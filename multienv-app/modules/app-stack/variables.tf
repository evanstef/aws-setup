# ===== INPUT module app-stack (ini "props"-nya) =====

variable "environment" {
  type        = string
  description = "Nama environment (staging/prod) — dipakai prefix nama resource biar unik per-env"
}

variable "db_password" {
  type        = string
  sensitive   = true
  description = "Password master RDS Postgres"
}

variable "instance_type" {
  type        = string
  default     = "t3.micro" # default kalau caller gak ngisi
  description = "Ukuran EC2 (mis. t3.micro buat staging, t3.medium buat prod)"
}

variable "app_domain" {
  type        = string
  description = "Domain aplikasi (mis. app.evnxc.web.id prod, app-staging.evnxc.web.id staging)"
}

variable "grafana_domain" {
  type        = string
  description = "Domain grafana per-env"
}

# ===== Input dari module network (biar resource masuk VPC kita) =====
variable "vpc_id" {
  type        = string
  description = "ID VPC tempat SG ditaro (dari module network)"
}

variable "public_subnet_id" {
  type        = string
  description = "ID public subnet buat EC2 web"
}

variable "db_subnet_group_name" {
  type        = string
  description = "Nama DB subnet group buat RDS (private subnet)"
}
