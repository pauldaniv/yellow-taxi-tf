data "tls_certificate" "eks" {
  url = module.eks.cluster_oidc_issuer_url
}
