module "zones" {
  source  = "terraform-aws-modules/route53/aws//modules/zones"
  version = "~> 2.0"

  zones = {
    "yellow-taxi.me" = {
      tags = {
        env = "yellow-taxi"
      }
    }
  }

  tags = {
    ManagedBy = "Terraform"
  }
}

module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 2.0"

  zone_name = keys(module.zones.route53_zone_zone_id)[0]

  records = [
    {
      name    = "apiv2"
      type    = "CNAME"
      ttl     = 300
      records = [
        "a53009e2179fe4609ae0d673c548c514-725e1682f5a19916.elb.us-east-2.amazonaws.com",
      ]
    },
  ]

  depends_on = [module.zones]
}


data "aws_iam_policy_document" "cert_manager_route53_policy" {
  statement {
    effect  = "Allow"
    actions = [
      "route53:GetChange",
      "secretsmanager:DescribeSecret"
    ]
    resources = ["arn:aws:route53:::change/*"]
  }

  statement {
    effect  = "Allow"
    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:ListResourceRecordSets"
    ]
    resources = [
      "arn:aws:route53:::hostedzone/${module.zones.route53_zone_zone_id[keys(module.zones.route53_zone_zone_id)[0]]}"
    ]
  }
}

data "aws_iam_policy_document" "cert_manager_route53_assume_policy" {
  statement {
    effect  = "Allow"
    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]
    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }
    condition {
      test     = "ForAnyValue:StringEquals"
      variable = "${module.eks.oidc_provider}:sub"
      values   = [
        "system:serviceaccount:cert-manager:cert-manager"
      ]
    }
  }
}

resource "aws_iam_role" "cert_manager_acme_role" {
  name               = "eks-cert-manager-acme"
  assume_role_policy = data.aws_iam_policy_document.cert_manager_route53_assume_policy.json
  tags               = {
    Project = "yellow-taxi"
  }
}

resource "aws_iam_policy" "cert_manager_policy" {
  name        = "cert_manager_policy"
  description = "Allows access to Route53"
  policy = data.aws_iam_policy_document.cert_manager_route53_policy.json
}

resource "aws_iam_policy_attachment" "cert_manager_role_policy_attachment" {
  name       = "cert_manager_role_policy_attachment"
  roles      = [aws_iam_role.cert_manager_acme_role.name]
  policy_arn = aws_iam_policy.cert_manager_policy.arn
}
