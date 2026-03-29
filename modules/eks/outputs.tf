output "cluster_name" {
  description = "EKS cluster name."
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "EKS API endpoint."
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_security_group_id" {
  description = "Cluster security group ID for private API access rules."
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate authority data for the EKS cluster."
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "oidc_provider_arn" {
  description = "OIDC provider ARN for the EKS cluster."
  value       = aws_iam_openid_connect_provider.this.arn
}

output "node_group_name" {
  description = "Managed node group name."
  value       = aws_eks_node_group.this.node_group_name
}

output "worker_node_security_group_id" {
  description = "Additional worker node security group ID."
  value       = aws_security_group.worker_nodes.id
}

output "load_balancer_controller_role_arn" {
  description = "IAM role ARN used by the AWS Load Balancer Controller service account."
  value       = aws_iam_role.load_balancer_controller.arn
}

output "external_secrets_role_arn" {
  description = "IAM role ARN used by the External Secrets service account."
  value       = aws_iam_role.external_secrets.arn
}
