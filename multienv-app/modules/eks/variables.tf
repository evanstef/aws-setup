variable "environment" {
    type        = string
    description = "Nama environment (staging/prod)"
}

variable "subnet_ids" {
    type        = list(string)
    description = "Subnet buat cluster EKS"
}
