output "private_eks_subnet_ids" {
  description = "Private subnet IDs used by the EKS cluster."
  value       = aws_subnet.private_eks[*].id
}

output "private_db_subnet_ids" {
  description = "Private subnet IDs used by the database tier."
  value       = aws_subnet.private_db[*].id
}
