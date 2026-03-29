output "vpc_id" {
  description = "VPC ID."
  value       = aws_vpc.this.id
}

output "availability_zones" {
  description = "Availability zones used by the VPC."
  value       = var.availability_zones
}

output "public_subnet_ids" {
  description = "Public subnet IDs."
  value       = aws_subnet.public[*].id
}

output "private_eks_subnet_ids" {
  description = "Private EKS subnet IDs."
  value       = aws_subnet.private_eks[*].id
}

output "private_db_subnet_ids" {
  description = "Private DB subnet IDs."
  value       = aws_subnet.private_db[*].id
}
