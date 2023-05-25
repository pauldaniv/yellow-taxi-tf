data "aws_iam_policy_document" "csi" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${module.eks.oidc_provider}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }

    principals {
      identifiers = [module.eks.oidc_provider_arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "eks_ebs_csi_driver" {
  assume_role_policy = data.aws_iam_policy_document.csi.json
  name               = "eks-ebs-csi-driver"
}

resource "aws_iam_role_policy_attachment" "amazon_ebs_csi_driver" {
  role       = aws_iam_role.eks_ebs_csi_driver.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

resource "aws_iam_policy_attachment" "eks_ebs_csi_driver_secrets_policy" {
  name       = "eks_ebs_csi_driver_secrets_policy"
  roles       = [aws_iam_role.eks_ebs_csi_driver.name]
  policy_arn = aws_iam_policy.secrets_manager_policy.arn
}

resource "aws_iam_policy_attachment" "eks_ebs_csi_driver_secrets_decrypt_policy" {
  name       = "eks_ebs_csi_driver_secrets_decrypt_policy"
  roles       = [aws_iam_role.eks_ebs_csi_driver.name]
  policy_arn = aws_iam_policy.decrypt_secrets_policy.arn
}
