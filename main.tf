provider "aws" {
  region = var.region
}

provider "aws" {
  alias  = "us-east-2"
  region = "us-east-2"
}

data "aws_availability_zones" "available" {}

locals {
  cluster_name = "education-eks-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

resource "aws_kms_key" "codeartifact" {
  provider                = aws.us-east-2
  deletion_window_in_days = 30
  enable_key_rotation     = true
  tags                    = merge({ "Name" = "codeartifact" }, var.tags)
}

resource "aws_codeartifact_domain" "promotion" {
  provider       = aws.us-east-2
  domain         = "promotion"
  encryption_key = aws_kms_key.codeartifact.arn
  tags           = merge({ "Name" = "codeartifact" }, var.tags)
}

resource "aws_codeartifact_repository" "promotion" {
  repository  = "releases"
  domain      = aws_codeartifact_domain.promotion.domain
  description = "Repository to install maven artifacts into"
  tags        = merge({ "Name" = "maven"}, var.tags)
}

data "aws_iam_policy_document" "codeartifact_repo_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions   = [
      "codeartifact:DescribePackageVersion",
      "codeartifact:DescribeRepository",
      "codeartifact:GetPackageVersionReadme",
      "codeartifact:GetRepositoryEndpoint",
      "codeartifact:ListPackageVersionAssets",
      "codeartifact:ListPackageVersionDependencies",
      "codeartifact:ListPackageVersions",
      "codeartifact:ListPackages",
      "codeartifact:PublishPackageVersion",
      "codeartifact:PutPackageMetadata",
      "codeartifact:ReadFromRepository"
    ]
    resources = ["*"]
  }
}

resource "aws_codeartifact_domain_permissions_policy" "promotion" {
  domain          = aws_codeartifact_domain.promotion.domain
  policy_document = data.aws_iam_policy_document.codeartifact_repo_policy.json
}

data "aws_iam_policy_document" "codeartifact_domain_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions   = [
      "codeartifact:CreateRepository",
      "codeartifact:DescribeDomain",
      "codeartifact:GetAuthorizationToken",
      "codeartifact:GetDomainPermissionsPolicy",
      "codeartifact:ListRepositoriesInDomain",
      "sts:GetServiceBearerToken"
    ]
    resources = [aws_codeartifact_domain.promotion.arn]
  }
}

resource "aws_codeartifact_repository_permissions_policy" "promotion" {
  domain          = aws_codeartifact_domain.promotion.domain
  policy_document = data.aws_iam_policy_document.codeartifact_domain_policy.json
  repository      = aws_codeartifact_repository.promotion.repository
}

resource "aws_ecr_repository" "taxi_trip_client" {
  name                 = "taxi-trip-client"
  image_tag_mutability = "MUTABLE"
  force_delete        = true
}

resource "aws_ecr_repository" "taxi_trip_api" {
  name                 = "taxi-trip-api"
  image_tag_mutability = "MUTABLE"
  force_delete        = true
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.19.0"

  name = "education-vpc"

  cidr = "10.0.0.0/16"
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = 1
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.5.1"

  cluster_name    = local.cluster_name
  cluster_version = "1.25"

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }


  eks_managed_node_groups = {
    one = {
      name = "node-group-1"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 3
      desired_size = 2
    }

    two = {
      name = "node-group-2"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 2
      desired_size = 1
    }
  }
}
