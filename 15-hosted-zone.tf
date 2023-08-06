module "zones" {
  source  = "terraform-aws-modules/route53/aws//modules/zones"
  version = "~> 2.0"

  zones = {
    "promotion-api.yellow-taxi.me" = {
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
      name    = "apigateway1"
      type    = "A"
      alias   = {
        name    = "d-10qxlbvagl.execute-api.eu-west-1.amazonaws.com"
        zone_id = "ZLY8HYME6SFAD"
      }
    },
    {
      name    = ""
      type    = "A"
      ttl     = 3600
      records = [
        "10.10.10.10",
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
    resources = ["arn:aws:route53:::hostedzone/${keys(module.zones.route53_zone_zone_id)[0]}"]
  }
}

resource "aws_iam_role" "cert_manager_acme" {
  name               = "eks-cert-manager-acme"
  assume_role_policy = data.aws_iam_policy_document.cert_manager_route53_policy.json
  tags               = {
    Project = "yellow-taxi"
  }
}
