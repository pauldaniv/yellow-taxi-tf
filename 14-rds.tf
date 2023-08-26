##resource "aws_subnet" "db_subnet" {
##  count = var.db_public_access ? length(var.public_db_subnets) : 0
##
##  vpc_id               = module.vpc.vpc_id
##  cidr_block           = var.public_db_subnets[count.index]
##  availability_zone    = length(regexall("^[a-z]{2}-", element(module.vpc.azs, count.index))) > 0 ? element(module.vpc.azs, count.index) : null
##  availability_zone_id = length(regexall("^[a-z]{2}-", element(module.vpc.azs, count.index))) == 0 ? element(module.vpc.azs, count.index) : null
##
##
##  tags = {
##    "Name" = format(
##      "yellow-taxi-db-%s",
##      element(module.vpc.azs, count.index),
##    )
##  }
##}
#
##resource "aws_route_table" "db_route_table" {
##  count  = var.db_public_access ? 1 : 0
##  vpc_id = module.vpc.vpc_id
##  tags   = {
##    "Name" = "main-db-public"
##  }
##}
#
##resource "aws_route_table_association" "db_route_table_association" {
##  count = var.db_public_access ? length(module.vpc.database_subnets) : 0
##
##  subnet_id      = element(aws_subnet.db_subnet[*].id, count.index)
##  route_table_id = aws_route_table.db_route_table[0].id
##}
##
##resource "aws_route" "database_internet_route" {
##  count                  = var.db_public_access ? 1 : 0
##  route_table_id         = aws_route_table.db_route_table[0].id
##  destination_cidr_block = "0.0.0.0/0"
##  gateway_id             = module.vpc.igw_id
##
##  timeouts {
##    create = "5m"
##  }
##}
#
##resource "aws_route" "database_nat_gateway" {
##  count = var.db_public_access == false ? 1 : 0
##
##  route_table_id         = element(aws_route_table.db_route_table[*].id, count.index)
##  destination_cidr_block = "0.0.0.0/0"
##  nat_gateway_id         = element(module.vpc.natgw_ids, count.index)
##
##  timeouts {
##    create = "5m"
##  }
##}
#
##resource "aws_db_subnet_group" "db_subnet_group" {
##  name        = "yt_db_sb_group"
##  description = "Database subnet group for database"
##  subnet_ids  = aws_subnet.db_subnet[*].id
##
##  tags = {
##    "Name" : "yellow-taxi"
##  }
##}
#
#
#resource "aws_security_group" "db_sg" {
#  name        = "db_sg"
#  description = "Postgres security group"
#  vpc_id      = module.vpc.vpc_id
#
#  ingress {
#    from_port   = 5432
#    to_port     = 5432
#    protocol    = "tcp"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#
#  tags = {
#    Name = "yellow-taxi-db-sg"
#  }
#}
#
##resource "aws_security_group_rule" "inbound_rule" {
##  protocol                 = "tcp"
##  type                     = "ingress"
##  from_port                = 5432
##  to_port                  = 5432
##  security_group_id        = aws_security_group.db_sg.id
##  source_security_group_id = module.eks.node_security_group_id
##}
#
#data "aws_secretsmanager_secret_version" "db" {
#  secret_id = "prod_yt_db_pass"
#}
#
#resource "aws_db_instance" "postgres" {
#  db_name           = "service"
#  username          = "service"
#  password          = data.aws_secretsmanager_secret_version.db.secret_string
#  engine            = "postgres"
#  engine_version    = "15"
#  instance_class    = "db.t4g.micro"
#  allocated_storage = 10
#
#  publicly_accessible    = true
#  skip_final_snapshot    = true
#  db_subnet_group_name   = module.vpc.database_subnet_group_name
#  vpc_security_group_ids = [aws_security_group.db_sg.id]
#}
#
#output "db_instance_url" {
#  value = aws_db_instance.postgres.endpoint
#}
