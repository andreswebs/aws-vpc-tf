data "aws_partition" "current" {}

locals {
  partition              = data.aws_partition.current.partition
  dns_suffix             = data.aws_partition.current.dns_suffix
  policy_arn_prefix      = "arn:${local.partition}:iam::aws:policy"
  pods_service_principal = "pods.eks.${local.dns_suffix}"
}

data "aws_iam_policy_document" "pods_trust" {
  statement {
    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
    principals {
      type        = "Service"
      identifiers = [local.pods_service_principal]
    }
  }

}

data "aws_eks_cluster" "this" {
  name = var.eks_cluster_name
}

locals {
  eks_cluster_oidc_provider = replace(data.aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")
}

locals {
  role = {
    lb_controller           = aws_iam_role.lb_controller
    cert_manager            = aws_iam_role.cert_manager
    external_secrets        = aws_iam_role.external_secrets
    opentelemetry_collector = aws_iam_role.opentelemetry_collector
    # external_dns            = aws_iam_role.external_dns
  }
}
