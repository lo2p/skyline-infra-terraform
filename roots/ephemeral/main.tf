data "terraform_remote_state" "persistent" {
  backend = "s3"

  config = {
    bucket = var.persistent_state_bucket
    key    = var.persistent_state_key
    region = var.persistent_state_region
  }
}

locals {
  cluster_name = data.terraform_remote_state.persistent.outputs.cluster_name
  common_tags  = data.terraform_remote_state.persistent.outputs.common_tags
}

module "network_private" {
  source = "../../modules/network_private"

  vpc_id                   = data.terraform_remote_state.persistent.outputs.vpc_id
  availability_zones       = data.terraform_remote_state.persistent.outputs.availability_zones
  public_subnet_id_for_nat = data.terraform_remote_state.persistent.outputs.public_subnet_ids[0]
  private_eks_subnet_cidrs = var.private_eks_subnet_cidrs
  private_db_subnet_cidrs  = var.private_db_subnet_cidrs
  cluster_name             = local.cluster_name
  tags                     = local.common_tags
}

module "eks" {
  source = "../../modules/eks"

  vpc_id                  = data.terraform_remote_state.persistent.outputs.vpc_id
  private_subnet_ids      = module.network_private.private_eks_subnet_ids
  eks_public_access_cidrs = var.eks_public_access_cidrs
  parameter_store_prefix  = var.parameter_store_prefix
  tags                    = local.common_tags
}

module "rds_mysql" {
  source = "../../modules/rds_mysql"

  vpc_id                        = data.terraform_remote_state.persistent.outputs.vpc_id
  private_db_subnet_ids         = module.network_private.private_db_subnet_ids
  worker_node_security_group_id = module.eks.worker_node_security_group_id
  admin_security_group_id       = data.terraform_remote_state.persistent.outputs.admin_security_group_id
  parameter_store_prefix        = var.parameter_store_prefix
  db_name                       = var.db_name
  db_username                   = var.db_username
  tags                          = local.common_tags
}

resource "aws_eks_access_entry" "admin" {
  cluster_name  = module.eks.cluster_name
  principal_arn = data.terraform_remote_state.persistent.outputs.admin_role_arn
  type          = "STANDARD"

  tags = local.common_tags
}

resource "aws_eks_access_policy_association" "admin_cluster_admin" {
  cluster_name  = module.eks.cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = data.terraform_remote_state.persistent.outputs.admin_role_arn

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.admin]
}

resource "aws_security_group_rule" "admin_to_cluster_private_endpoint_https" {
  description              = "Allow the admin EC2 instance to reach the EKS private API endpoint."
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = module.eks.cluster_security_group_id
  source_security_group_id = data.terraform_remote_state.persistent.outputs.admin_security_group_id
}
