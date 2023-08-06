#module "route53" {
#  source  = "mineiros-io/route53/aws"
#  version = "~> 0.6.0"
#
#  name = "a-dev-mineiros.io"
#}
#
#data "aws_iam_policy_document" "cert_manager_route53_policy" {
#  statement {
#    effect  = "Allow"
#    actions = [
#      "route53:GetChange",
#      "secretsmanager:DescribeSecret"
#    ]
#    resources = ["arn:aws:route53:::change/*"]
#  }
#
#  statement {
#    effect  = "Allow"
#    actions = [
#      "route53:ChangeResourceRecordSets",
#      "route53:ListResourceRecordSets"
#    ]
#    resources = ["arn:aws:route53:::hostedzone/${module.route53.outputs.zoreId}"]
#  }
#}
#
#resource "aws_iam_role" "cert_manager_acme" {
#  name               = "eks-cert-manager-acme"
#  assume_role_policy = data.aws_iam_policy_document.assume-service-account-secrets-policy.json
#  tags               = {
#    Project = "yellow-taxi"
#  }
#}
