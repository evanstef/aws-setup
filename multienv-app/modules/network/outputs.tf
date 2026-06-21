output "vpc_id" {
  value       = aws_vpc.main.id
  description = "ID of the VPC"
}

output "public_subnet_id" {
  value       = aws_subnet.public.id
  description = "ID of the public subnet"
}

output "private_subnet_id" {
  value       = aws_subnet.private.id
  description = "ID of the private subnet"
}

output "db_subnet_group_name" {
  value       = aws_db_subnet_group.main.name
  description = "Nama DB subnet group buat RDS"
}

output "private_subnet_ids" {
  value       = [aws_subnet.private.id, aws_subnet.private_2.id]
  description = "List private subnet (2 AZ) buat EKS"
}
