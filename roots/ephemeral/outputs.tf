output "eks_cluster_name" {
  description = "EKS cluster name."
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS cluster API server endpoint."
  value       = module.eks.cluster_endpoint
}

output "eks_oidc_provider_arn" {
  description = "IAM OIDC provider ARN for the EKS cluster."
  value       = module.eks.oidc_provider_arn
}

output "aws_load_balancer_controller_role_arn" {
  description = "IAM role ARN used by the AWS Load Balancer Controller service account."
  value       = module.eks.load_balancer_controller_role_arn
}

output "external_secrets_role_arn" {
  description = "IAM role ARN used by the External Secrets service account."
  value       = module.eks.external_secrets_role_arn
}

output "eks_node_group_name" {
  description = "Managed node group name."
  value       = module.eks.node_group_name
}

output "kubeconfig_command" {
  description = "Example command to update local kubeconfig for the cluster."
  value       = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.aws_region}"
}

output "db_endpoint" {
  description = "RDS instance endpoint."
  value       = module.rds_mysql.endpoint
}

output "db_port" {
  description = "RDS MySQL port."
  value       = module.rds_mysql.port
}

output "db_name" {
  description = "Application database name."
  value       = module.rds_mysql.db_name
}

output "db_parameter_names" {
  description = "SSM parameter names containing database connection details."
  value       = module.rds_mysql.parameter_names
}
