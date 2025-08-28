resource "aws_iam_role" "cert_manager" {
  name = "cert-manager-${var.eks_cluster_name}"

  assume_role_policy    = data.aws_iam_policy_document.pods_trust.json
  force_detach_policies = true
  tags                  = var.tags
}

resource "aws_iam_role_policy" "cert_manager" {
  name   = "cert-manager-permissions"
  role   = aws_iam_role.cert_manager.id
  policy = file("${path.module}/tpl/manage-route53.json")
}

resource "aws_eks_pod_identity_association" "cert_manager" {
  cluster_name    = var.eks_cluster_name
  role_arn        = aws_iam_role.cert_manager.arn
  namespace       = "cert-manager"
  service_account = "cert-manager"
}
