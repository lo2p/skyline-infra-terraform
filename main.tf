data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ecr_repository" "existing" {
  name = var.existing_ecr_repository_name
}

locals {
  cluster_name = "skyline-system-demo-eks"

  common_tags = {
    Project     = "skyline-system-demo"
    Environment = "demo"
    ManagedBy   = "terraform"
  }
}

module "vpc" {
  source = "./modules/vpc"

  vpc_cidr                 = var.vpc_cidr
  availability_zones       = slice(data.aws_availability_zones.available.names, 0, 2)
  public_subnet_cidrs      = var.public_subnet_cidrs
  private_eks_subnet_cidrs = var.private_eks_subnet_cidrs
  private_db_subnet_cidrs  = var.private_db_subnet_cidrs
  cluster_name             = local.cluster_name
  tags                     = local.common_tags
}

module "admin_ec2" {
  source = "./modules/admin_ec2"

  vpc_id                            = module.vpc.vpc_id
  public_subnet_id                  = module.vpc.public_subnet_ids[0]
  key_pair_name                     = var.key_pair_name
  admin_access_cidr                 = var.admin_access_cidr
  parameter_store_prefix            = var.parameter_store_prefix
  ecr_repository_arn                = data.aws_ecr_repository.existing.arn
  aws_region                        = var.aws_region
  cluster_name                      = local.cluster_name
  load_balancer_controller_role_arn = module.eks.load_balancer_controller_role_arn
  external_secrets_role_arn         = module.eks.external_secrets_role_arn
  tags                              = local.common_tags
}

module "eks" {
  source = "./modules/eks"

  vpc_id                  = module.vpc.vpc_id
  private_subnet_ids      = module.vpc.private_eks_subnet_ids
  eks_public_access_cidrs = var.eks_public_access_cidrs
  parameter_store_prefix  = var.parameter_store_prefix
  tags                    = local.common_tags
}

module "rds_mysql" {
  source = "./modules/rds_mysql"

  vpc_id                        = module.vpc.vpc_id
  private_db_subnet_ids         = module.vpc.private_db_subnet_ids
  worker_node_security_group_id = module.eks.worker_node_security_group_id
  admin_security_group_id       = module.admin_ec2.security_group_id
  parameter_store_prefix        = var.parameter_store_prefix
  db_name                       = var.db_name
  db_username                   = var.db_username
  tags                          = local.common_tags
}

resource "aws_eks_access_entry" "admin" {
  # IAM permissions on the EC2 role let it call AWS APIs, but this access entry
  # is what authorizes that role inside the Kubernetes cluster.
  cluster_name  = module.eks.cluster_name
  principal_arn = module.admin_ec2.role_arn
  type          = "STANDARD"

  tags = local.common_tags
}

resource "aws_eks_access_policy_association" "admin_cluster_admin" {
  cluster_name  = module.eks.cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = module.admin_ec2.role_arn

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
  source_security_group_id = module.admin_ec2.security_group_id
}
