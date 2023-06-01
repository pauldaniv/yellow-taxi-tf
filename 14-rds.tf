resource "aws_db_subnet_group" "db" {
  name       = "private-subnet"
  subnet_ids = concat(
    module.vpc.private_subnets,
    module.vpc.public_subnets
  )

  tags = {
    Name = "yellow-taxi"
  }
}

data "aws_secretsmanager_secret_version" "db" {
  secret_id = "prod_yt_db_pass"
}

resource "aws_db_instance" "postgres" {
  db_name           = "service"
  username = "service"
  password = data.aws_secretsmanager_secret_version.db.secret_string
  engine            = "postgres"
  engine_version    = "15"
  instance_class    = "db.t4g.micro"
  allocated_storage = 10

  publicly_accessible  = true
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.db.name
  vpc_security_group_ids = [module.vpc.default_security_group_id]
}

output "db_instance_url" {
  value = aws_db_instance.postgres.endpoint
}
