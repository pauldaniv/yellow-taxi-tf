resource "aws_db_subnet_group" "public" {
  name       = "public"
  subnet_ids = module.vpc.public_subnets
}


data "aws_secretsmanager_secret_version" "creds" {
  secret_id = "db-creds-v1"
}

locals {
  db_creds = jsondecode(
    data.aws_secretsmanager_secret_version.creds.secret_string
  )
}

resource "aws_db_instance" "mydb" {
  db_name           = "service"
  engine            = "postgres"
  engine_version    = "15"
  instance_class    = "db.t4g.micro"
  allocated_storage = 10

  publicly_accessible  = true
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.public.name

  username = local.db_creds.username
  password = local.db_creds.password
}
