# Migration Runbook

This runbook moves the existing monolithic state into the new split roots without recreating infrastructure.

## Preparation

1. Back up the existing state.
2. Confirm the new roots validate locally.
3. Do not apply the new roots until state has been moved.

Suggested backup flow:

```bash
mkdir migration
terraform state pull > migration/legacy.tfstate
```

Initialize the destination roots before pushing migrated state:

```bash
terraform -chdir=roots/persistent init
terraform -chdir=roots/ephemeral init
```

## Move Resources Into Persistent State

Run these commands from the repository root:

```bash
terraform state mv -state=migration/legacy.tfstate -state-out=migration/persistent.tfstate module.vpc.aws_vpc.this module.network_public.aws_vpc.this
terraform state mv -state=migration/legacy.tfstate -state-out=migration/persistent.tfstate module.vpc.aws_internet_gateway.this module.network_public.aws_internet_gateway.this
terraform state mv -state=migration/legacy.tfstate -state-out=migration/persistent.tfstate module.vpc.aws_subnet.public[0] module.network_public.aws_subnet.public[0]
terraform state mv -state=migration/legacy.tfstate -state-out=migration/persistent.tfstate module.vpc.aws_subnet.public[1] module.network_public.aws_subnet.public[1]
terraform state mv -state=migration/legacy.tfstate -state-out=migration/persistent.tfstate module.vpc.aws_route_table.public module.network_public.aws_route_table.public
terraform state mv -state=migration/legacy.tfstate -state-out=migration/persistent.tfstate module.vpc.aws_route.public_internet module.network_public.aws_route.public_internet
terraform state mv -state=migration/legacy.tfstate -state-out=migration/persistent.tfstate module.vpc.aws_route_table_association.public[0] module.network_public.aws_route_table_association.public[0]
terraform state mv -state=migration/legacy.tfstate -state-out=migration/persistent.tfstate module.vpc.aws_route_table_association.public[1] module.network_public.aws_route_table_association.public[1]
terraform state mv -state=migration/legacy.tfstate -state-out=migration/persistent.tfstate module.admin_ec2 module.admin_ec2
```

## Move Resources Into Ephemeral State

Run these commands from the repository root:

```bash
terraform state mv -state=migration/legacy.tfstate -state-out=migration/ephemeral.tfstate module.vpc.aws_subnet.private_eks[0] module.network_private.aws_subnet.private_eks[0]
terraform state mv -state=migration/legacy.tfstate -state-out=migration/ephemeral.tfstate module.vpc.aws_subnet.private_eks[1] module.network_private.aws_subnet.private_eks[1]
terraform state mv -state=migration/legacy.tfstate -state-out=migration/ephemeral.tfstate module.vpc.aws_subnet.private_db[0] module.network_private.aws_subnet.private_db[0]
terraform state mv -state=migration/legacy.tfstate -state-out=migration/ephemeral.tfstate module.vpc.aws_subnet.private_db[1] module.network_private.aws_subnet.private_db[1]
terraform state mv -state=migration/legacy.tfstate -state-out=migration/ephemeral.tfstate module.vpc.aws_eip.nat module.network_private.aws_eip.nat
terraform state mv -state=migration/legacy.tfstate -state-out=migration/ephemeral.tfstate module.vpc.aws_nat_gateway.this module.network_private.aws_nat_gateway.this
terraform state mv -state=migration/legacy.tfstate -state-out=migration/ephemeral.tfstate module.vpc.aws_route_table.private_eks module.network_private.aws_route_table.private_eks
terraform state mv -state=migration/legacy.tfstate -state-out=migration/ephemeral.tfstate module.vpc.aws_route.private_eks_nat module.network_private.aws_route.private_eks_nat
terraform state mv -state=migration/legacy.tfstate -state-out=migration/ephemeral.tfstate module.vpc.aws_route_table_association.private_eks[0] module.network_private.aws_route_table_association.private_eks[0]
terraform state mv -state=migration/legacy.tfstate -state-out=migration/ephemeral.tfstate module.vpc.aws_route_table_association.private_eks[1] module.network_private.aws_route_table_association.private_eks[1]
terraform state mv -state=migration/legacy.tfstate -state-out=migration/ephemeral.tfstate module.vpc.aws_route_table.private_db module.network_private.aws_route_table.private_db
terraform state mv -state=migration/legacy.tfstate -state-out=migration/ephemeral.tfstate module.vpc.aws_route.private_db_nat module.network_private.aws_route.private_db_nat
terraform state mv -state=migration/legacy.tfstate -state-out=migration/ephemeral.tfstate module.vpc.aws_route_table_association.private_db[0] module.network_private.aws_route_table_association.private_db[0]
terraform state mv -state=migration/legacy.tfstate -state-out=migration/ephemeral.tfstate module.vpc.aws_route_table_association.private_db[1] module.network_private.aws_route_table_association.private_db[1]
terraform state mv -state=migration/legacy.tfstate -state-out=migration/ephemeral.tfstate module.eks module.eks
terraform state mv -state=migration/legacy.tfstate -state-out=migration/ephemeral.tfstate module.rds_mysql module.rds_mysql
terraform state mv -state=migration/legacy.tfstate -state-out=migration/ephemeral.tfstate aws_eks_access_entry.admin aws_eks_access_entry.admin
terraform state mv -state=migration/legacy.tfstate -state-out=migration/ephemeral.tfstate aws_eks_access_policy_association.admin_cluster_admin aws_eks_access_policy_association.admin_cluster_admin
terraform state mv -state=migration/legacy.tfstate -state-out=migration/ephemeral.tfstate aws_security_group_rule.admin_to_cluster_private_endpoint_https aws_security_group_rule.admin_to_cluster_private_endpoint_https
```

## Push Migrated States

Push the migrated state files into the new backends:

```bash
terraform -chdir=roots/persistent state push ../../migration/persistent.tfstate
terraform -chdir=roots/ephemeral state push ../../migration/ephemeral.tfstate
```

Keep `migration/legacy.tfstate` as a rollback artifact until the new roots are fully validated.

## Post-Migration Validation

1. `terraform -chdir=roots/persistent plan -var-file=terraform.tfvars`
2. `terraform -chdir=roots/ephemeral plan -var-file=terraform.tfvars`
3. Confirm both plans are no-op or contain only intentional drift fixes.
4. Run `terraform -chdir=roots/ephemeral destroy -var-file=terraform.tfvars` as a review step and confirm the bastion and public network are not targeted.
5. Re-apply the ephemeral root and validate bastion access, EKS nodes, ALB controller deployment, and RDS parameters.
