resource "aws_db_subnet_group" "public" {
  name       = "public"
  subnet_ids = module.vpc.public_subnets
}


data "aws_secretsmanager_secret_version" "db" {
  secret_id = "prot_yt_db"
}

resource "aws_db_instance" "postgres" {
  db_name           = "service"
  engine            = "postgres"
  engine_version    = "15"
  instance_class    = "db.t4g.micro"
  allocated_storage = 10

  publicly_accessible  = true
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.public.name

  username = "service"
  password = data.aws_secretsmanager_secret_version.db.secret_string
}

output "db_instance_url" {
  value = aws_db_instance.postgres.endpoint
}
