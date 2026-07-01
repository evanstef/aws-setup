variable "environment" {
    description = "Nama environment (staging/prod) buat prefix nama resource biar gak bentrok antar-env"
    type = string
}

variable "target_group_vpc_id" {
    description = "VPC ID tempat target group + server berada"
    type = string
}

variable "public_subnet_ids" {
    description = "Public subnet IDs (2 AZ) buat ALB internet-facing"
    type = list(string)
}

variable "private_subnet_ids" {
    description = "Private subnet IDs (2 AZ) buat server ASG (aman, cuma dijangkau ALB)"
    type = list(string)
}

variable "domain_name" {
    description = "domain name untuk SSL certificate"
    type = string
}