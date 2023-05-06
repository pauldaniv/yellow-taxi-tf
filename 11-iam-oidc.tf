data "tls_certificate" "eks" {
  url = module.eks.cluster_identity_providers.oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = module.eks.cluster_identity_providers.oidc[0].issuer
}
