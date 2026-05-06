data "aws_region" "current" {}

locals {
  tags = merge(var.tags, { Name = var.name })
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = local.tags
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = local.tags
}

resource "aws_subnet" "public" {
  for_each = var.public_subnets

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr_block
  availability_zone       = "${data.aws_region.current.name}${each.key}"
  map_public_ip_on_launch = true

  tags = merge(local.tags, { Name = "${var.name}-public-${each.key}", Tier = "public" })
}

resource "aws_subnet" "private" {
  for_each = var.private_subnets

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr_block
  availability_zone = "${data.aws_region.current.name}${each.key}"

  tags = merge(local.tags, { Name = "${var.name}-private-${each.key}", Tier = "private" })
}

resource "aws_eip" "nat" {
  for_each = var.public_subnets
  domain   = "vpc"

  tags = merge(local.tags, { Name = "${var.name}-nat-eip-${each.key}" })
}

resource "aws_nat_gateway" "this" {
  for_each = var.public_subnets

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[each.key].id

  tags = merge(local.tags, { Name = "${var.name}-nat-${each.key}" })

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(local.tags, { Name = "${var.name}-rt-public", Tier = "public" })
}

resource "aws_route_table_association" "public" {
  for_each = var.public_subnets

  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  for_each = var.private_subnets

  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this[each.key].id
  }

  tags = merge(local.tags, { Name = "${var.name}-rt-private-${each.key}", Tier = "private" })
}

resource "aws_route_table_association" "private" {
  for_each = var.private_subnets

  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = concat(
    [aws_route_table.public.id],
    values(aws_route_table.private)[*].id
  )

  tags = merge(local.tags, { Name = "${var.name}-s3-endpoint" })
}

resource "aws_security_group" "load_balancer_sg" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.tags, { Name = "${var.name}-lb-sg" })
}

resource "aws_vpc_security_group_ingress_rule" "lb_http" {
  security_group_id = aws_security_group.load_balancer_sg.id
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "lb_https" {
  security_group_id = aws_security_group.load_balancer_sg.id
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "lb_egress" {
  security_group_id = aws_security_group.load_balancer_sg.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_security_group" "app_server_sg" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.tags, { Name = "${var.name}-app-sg" })
}

resource "aws_vpc_security_group_ingress_rule" "app_http" {
  security_group_id            = aws_security_group.app_server_sg.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.load_balancer_sg.id
}

resource "aws_vpc_security_group_egress_rule" "app_egress" {
  security_group_id = aws_security_group.app_server_sg.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}
