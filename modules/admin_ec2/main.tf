locals {
  eks_setup_script = templatefile("${path.module}/templates/skyline-setup-eks.sh.tftpl", {
    aws_region                         = var.aws_region
    cluster_name                       = var.cluster_name
    vpc_id                             = var.vpc_id
    parameter_store_prefix             = var.parameter_store_prefix
    load_balancer_controller_role_arn  = var.load_balancer_controller_role_arn
    load_balancer_controller_role_name = var.load_balancer_controller_role_name
    external_secrets_role_arn          = var.external_secrets_role_arn
    external_secrets_role_name         = var.external_secrets_role_name
  })
}

data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64"
}

resource "aws_security_group" "this" {
  name        = "skyline-system-demo-admin-sg"
  description = "Security group for the Skyline demo admin instance."
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from the allowed admin CIDR"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_access_cidr]
  }

  egress {
    description = "Allow outbound access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "skyline-system-demo-admin-sg"
  })
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "this" {
  name               = "skyline-system-demo-admin-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "administrator_access" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_instance_profile" "this" {
  name = "skyline-system-demo-admin-profile"
  role = aws_iam_role.this.name
}

resource "aws_instance" "this" {
  ami                         = data.aws_ssm_parameter.al2023_ami.value
  instance_type               = "t3.small"
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [aws_security_group.this.id]
  associate_public_ip_address = true
  key_name                    = var.key_pair_name
  iam_instance_profile        = aws_iam_instance_profile.this.name
  user_data_replace_on_change = true
  user_data = templatefile("${path.module}/user_data.sh", {
    eks_setup_script_contents = local.eks_setup_script
  })

  tags = merge(var.tags, {
    Name = "skyline-system-demo-admin"
  })
}
