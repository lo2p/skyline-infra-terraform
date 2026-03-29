resource "aws_subnet" "private_eks" {
  count = 2

  vpc_id            = var.vpc_id
  cidr_block        = var.private_eks_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(var.tags, {
    Name                                        = "skyline-system-demo-private-eks-${count.index + 1}"
    Tier                                        = "private"
    Purpose                                     = "eks"
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  })
}

resource "aws_subnet" "private_db" {
  count = 2

  vpc_id            = var.vpc_id
  cidr_block        = var.private_db_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(var.tags, {
    Name    = "skyline-system-demo-private-db-${count.index + 1}"
    Tier    = "private"
    Purpose = "database"
  })
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = merge(var.tags, {
    Name = "skyline-system-demo-nat-eip"
  })
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = var.public_subnet_id_for_nat

  tags = merge(var.tags, {
    Name = "skyline-system-demo-nat"
  })
}

resource "aws_route_table" "private_eks" {
  vpc_id = var.vpc_id

  tags = merge(var.tags, {
    Name = "skyline-system-demo-private-eks-rt"
  })
}

resource "aws_route" "private_eks_nat" {
  route_table_id         = aws_route_table.private_eks.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id
}

resource "aws_route_table_association" "private_eks" {
  count = 2

  subnet_id      = aws_subnet.private_eks[count.index].id
  route_table_id = aws_route_table.private_eks.id
}

resource "aws_route_table" "private_db" {
  vpc_id = var.vpc_id

  tags = merge(var.tags, {
    Name = "skyline-system-demo-private-db-rt"
  })
}

resource "aws_route" "private_db_nat" {
  route_table_id         = aws_route_table.private_db.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id
}

resource "aws_route_table_association" "private_db" {
  count = 2

  subnet_id      = aws_subnet.private_db[count.index].id
  route_table_id = aws_route_table.private_db.id
}
