# skyline-infra-terraform

Terraform for the Skyline demo AWS environment.

The recommended operating model uses two roots:

- `roots/persistent`: long-lived access plane
- `roots/ephemeral`: disposable workload plane

This keeps the admin EC2 and public network stable while allowing EKS, NAT, private subnets, and RDS to be recreated as needed.

## Architecture

Persistent root owns:

- shared VPC
- Internet Gateway
- public subnets and route table
- admin EC2, IAM role, instance profile, and security group
- existing ECR repository lookup

Ephemeral root owns:

- private EKS and DB subnets
- NAT gateway and private route tables
- EKS cluster, node group, add-ons, and OIDC provider
- AWS Load Balancer Controller IAM role
- External Secrets IAM role
- EKS access for the admin EC2 role
- RDS MySQL
- SSM Parameter Store values for database connection details

## Repository Layout

- `roots/persistent`
- `roots/ephemeral`
- `modules/network_public`
- `modules/network_private`
- `modules/admin_ec2`
- `modules/eks`
- `modules/rds_mysql`
- `docs/migration-runbook.md`

The repo root still contains the legacy combined root, but day-to-day work should use `roots/persistent` and `roots/ephemeral`.

## Prerequisites

- Terraform `1.14.x`
- AWS credentials with permission to manage VPC, EC2, EKS, RDS, IAM, and SSM
- an existing EC2 key pair in the target account and region
- AWS CLI for kubeconfig and ECR login workflows

## Configuration

Copy and populate the root-specific examples:

```bash
cp roots/persistent/terraform.tfvars.example roots/persistent/terraform.tfvars
cp roots/ephemeral/terraform.tfvars.example roots/ephemeral/terraform.tfvars
```

Important persistent values:

- `key_pair_name`
- `admin_access_cidr`
- `public_subnet_cidrs`
- `existing_ecr_repository_name`

Important ephemeral values:

- `eks_public_access_cidrs`
- `private_eks_subnet_cidrs`
- `private_db_subnet_cidrs`
- `parameter_store_prefix`
- `db_name`
- `db_username`

## Workflow

Initialize each root:

```bash
terraform -chdir=roots/persistent init
terraform -chdir=roots/ephemeral init
```

Create or update the long-lived access plane:

```bash
terraform -chdir=roots/persistent plan
terraform -chdir=roots/persistent apply
```

Create or update the workload plane:

```bash
terraform -chdir=roots/ephemeral plan
terraform -chdir=roots/ephemeral apply
```

Cost cleanup:

```bash
terraform -chdir=roots/ephemeral destroy
```

## Bastion Setup

The admin EC2 writes a helper script:

- `/usr/local/bin/skyline-setup-eks.sh`

Run it after the ephemeral root has been applied:

```bash
sudo /usr/local/bin/skyline-setup-eks.sh
```

The script will:

- update kubeconfig for `root` and `ec2-user`
- install or upgrade AWS Load Balancer Controller
- install External Secrets CRDs and then install or upgrade External Secrets
- create the `skyline` namespace
- create a `SecretStore` and `ExternalSecret`
- sync the existing SSM database parameters into the Kubernetes secret `skyline-db-secret`

Parameter Store remains managed by Terraform. The bootstrap script only connects Kubernetes to those existing parameters.
The database password is stored as a `SecureString`, so the External Secrets IAM role must also be able to call `kms:Decrypt`.

## Apply Impact

When the persistent root changes the admin instance `user_data`, Terraform replaces that EC2 instance because `user_data_replace_on_change = true`.

That means this update typically causes:

- `roots/persistent`: replace admin EC2, update admin security group if needed
- `roots/ephemeral`: create External Secrets IAM role, policy, and attachment

It does not intentionally recreate the VPC, EKS cluster, RDS instance, or existing SSM parameters.

Always confirm with `terraform plan` before apply.

## Validation

After apply, verify from the admin EC2:

```bash
sudo /usr/local/bin/skyline-setup-eks.sh
kubectl get nodes
kubectl get crd externalsecrets.external-secrets.io secretstores.external-secrets.io
kubectl get deployment -n kube-system aws-load-balancer-controller
kubectl get deployment -n external-secrets external-secrets
kubectl get secret -n skyline skyline-db-secret
```

## Migration

Use [docs/migration-runbook.md](/c:/Users/M/Desktop/code/skyline-infra-terraform/docs/migration-runbook.md) to move state safely from the legacy combined root into the split `persistent` and `ephemeral` roots.
