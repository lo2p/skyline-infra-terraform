resource "random_password" "db" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_db_subnet_group" "this" {
  name       = "skyline-system-demo-db-subnets"
  subnet_ids = var.private_db_subnet_ids

  tags = merge(var.tags, {
    Name = "skyline-system-demo-db-subnets"
  })
}

resource "aws_security_group" "this" {
  name        = "skyline-system-demo-db-sg"
  description = "Security group for the Skyline demo MySQL database."
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL from EKS worker nodes"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.worker_node_security_group_id]
  }

  ingress {
    description     = "MySQL from the admin EC2 instance"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.admin_security_group_id]
  }

  egress {
    description = "Allow outbound access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "skyline-system-demo-db-sg"
  })
}

resource "aws_db_instance" "this" {
  identifier                   = "skyline-system-demo-mysql"
  engine                       = "mysql"
  instance_class               = "db.t3.micro"
  allocated_storage            = 20
  storage_type                 = "gp3"
  storage_encrypted            = true
  db_name                      = var.db_name
  username                     = var.db_username
  password                     = random_password.db.result
  db_subnet_group_name         = aws_db_subnet_group.this.name
  vpc_security_group_ids       = [aws_security_group.this.id]
  publicly_accessible          = false
  multi_az                     = false
  backup_retention_period      = 0
  deletion_protection          = false
  skip_final_snapshot          = true
  apply_immediately            = true
  auto_minor_version_upgrade   = true
  performance_insights_enabled = false
  monitoring_interval          = 0
  copy_tags_to_snapshot        = true

  tags = merge(var.tags, {
    Name = "skyline-system-demo-mysql"
  })
}

resource "aws_ssm_parameter" "db_host" {
  name  = "${var.parameter_store_prefix}/database/host"
  type  = "String"
  value = aws_db_instance.this.address

  tags = var.tags
}

resource "aws_ssm_parameter" "db_port" {
  name  = "${var.parameter_store_prefix}/database/port"
  type  = "String"
  value = tostring(aws_db_instance.this.port)

  tags = var.tags
}

resource "aws_ssm_parameter" "db_name" {
  name  = "${var.parameter_store_prefix}/database/name"
  type  = "String"
  value = var.db_name

  tags = var.tags
}

resource "aws_ssm_parameter" "db_username" {
  name  = "${var.parameter_store_prefix}/database/username"
  type  = "String"
  value = var.db_username

  tags = var.tags
}

resource "aws_ssm_parameter" "db_password" {
  name  = "${var.parameter_store_prefix}/database/password"
  type  = "SecureString"
  value = random_password.db.result

  tags = var.tags
}
