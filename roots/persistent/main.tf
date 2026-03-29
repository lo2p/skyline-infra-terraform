data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ecr_repository" "existing" {
  name = var.existing_ecr_repository_name
}

locals {
  cluster_name                       = "skyline-system-demo-eks"
  load_balancer_controller_role_name = "skyline-system-demo-aws-load-balancer-controller-role"
  external_secrets_role_name         = "skyline-system-demo-external-secrets-role"

  common_tags = {
    Project     = "skyline-system-demo"
    Environment = "demo"
    ManagedBy   = "terraform"
  }
}

module "network_public" {
  source = "../../modules/network_public"

  vpc_cidr            = var.vpc_cidr
  availability_zones  = slice(data.aws_availability_zones.available.names, 0, 2)
  public_subnet_cidrs = var.public_subnet_cidrs
  cluster_name        = local.cluster_name
  tags                = local.common_tags
}

module "admin_ec2" {
  source = "../../modules/admin_ec2"

  vpc_id                             = module.network_public.vpc_id
  public_subnet_id                   = module.network_public.public_subnet_ids[0]
  key_pair_name                      = var.key_pair_name
  admin_access_cidr                  = var.admin_access_cidr
  parameter_store_prefix             = var.parameter_store_prefix
  ecr_repository_arn                 = data.aws_ecr_repository.existing.arn
  aws_region                         = var.aws_region
  cluster_name                       = local.cluster_name
  load_balancer_controller_role_name = local.load_balancer_controller_role_name
  external_secrets_role_name         = local.external_secrets_role_name
  tags                               = local.common_tags
}
