variable "db_public_access" {
  type = bool
  default = false
}

resource "aws_route_table" "db_public_route_table" {
  count = var.db_public_access ? 1 : 0
  vpc_id = module.vpc.vpc_id
  tags   = {
    "Name" = "main-public-db"
  }
}

resource "aws_route_table_association" "db_public" {
  count = var.db_public_access ? length(module.vpc.database_subnets) : 0

  subnet_id      = element(aws_subnet.public_db[*].id, count.index)
  route_table_id = element(
    coalescelist(aws_route_table.db_public_route_table[*].id), count.index
  )
}

resource "aws_route" "database_internet_gateway" {
  count = var.db_public_access ? 1 : 0
  route_table_id         = aws_route_table.db_public_route_table[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = module.vpc.igw_id

  timeouts {
    create = "5m"
  }
}

resource "aws_db_subnet_group" "database" {
  name        = "yt_db_sb_group"
  description = "Database subnet group for database"
  subnet_ids  = concat(module.vpc.database_subnets, aws_subnet.public_db[*].id)

  tags = {
    "Name" : "yellow-taxi"
  }
}
variable "public_db_subnets" {
  type    = list(string)
  default = [
    "10.0.150.0/24",
    "10.0.151.0/24",
    "10.0.152.0/24",
    "10.0.153.0/24"
  ]
}

resource "aws_subnet" "public_db" {
  count = var.db_public_access ? length(var.public_db_subnets): 0

  vpc_id               = module.vpc.vpc_id
  cidr_block           = var.public_db_subnets[count.index]
  availability_zone    = length(regexall("^[a-z]{2}-", element(module.vpc.azs, count.index))) > 0 ? element(module.vpc.azs, count.index) : null
  availability_zone_id = length(regexall("^[a-z]{2}-", element(module.vpc.azs, count.index))) == 0 ? element(module.vpc.azs, count.index) : null


  tags = {
    "Name" = format(
      "yellow-taxi-%s",
      element(module.vpc.azs, count.index),
    )
  }
}


resource "aws_security_group" "db_sg" {
  // Basic details like the name and description of the SG
  name        = "db_sg"
  description = "Security group for tutorial databases"
  // We want the SG to be in the "tutorial_vpc" VPC
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = "5432"
    to_port     = "5432"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "yellow-taxi-db-sg"
  }
}

data "aws_secretsmanager_secret_version" "db" {
  secret_id = "prod_yt_db_pass"
}


resource "aws_db_instance" "postgres" {
  db_name           = "service"
  username          = "service"
  password          = data.aws_secretsmanager_secret_version.db.secret_string
  engine            = "postgres"
  engine_version    = "15"
  instance_class    = "db.t4g.micro"
  allocated_storage = 10

  publicly_accessible    = true
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.database.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
}

output "db_instance_url" {
  value = aws_db_instance.postgres.endpoint
}
