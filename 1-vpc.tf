module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.3"

  name = "main"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-2a", "us-east-2b"]
  private_subnets = ["10.0.0.0/19", "10.0.32.0/19"]
  public_subnets  = ["10.0.64.0/19", "10.0.96.0/19"]

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }

  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = false
  database_subnets       = var.db_subnets

  create_database_subnet_group           = true
  create_database_subnet_route_table     = true
  create_database_nat_gateway_route      = var.db_public_access == false
  create_database_internet_gateway_route = var.db_public_access
  enable_dns_hostnames                   = true
  enable_dns_support                     = true
  tags                                   = {
    Project     = "yellow-taxi"
  }
}
