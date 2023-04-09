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


resource "aws_codeartifact_domain_permissions_policy" "promotion" {
  domain          = aws_codeartifact_domain.promotion.domain
  policy_document = data.aws_iam_policy_document.codeartifact_repo_policy.json
}

resource "aws_codeartifact_repository_permissions_policy" "promotion" {
  domain          = aws_codeartifact_domain.promotion.domain
  policy_document = data.aws_iam_policy_document.codeartifact_domain_policy.json
  repository      = aws_codeartifact_repository.promotion.repository
}
