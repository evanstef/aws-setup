variable "target_group_vpc_id" {
    description = "VPC ID"
    type = string
}

variable "aws_lb_subnet_ids" {
    description = "Subnet IDs"
    type = list(string)
}