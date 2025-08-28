resource "aws_iam_role" "opentelemetry_collector" {
  name = "opentelemetry-collector-${var.eks_cluster_name}"

  assume_role_policy    = data.aws_iam_policy_document.pods_trust.json
  force_detach_policies = true
  tags                  = var.tags
}

resource "aws_iam_role_policy_attachment" "opentelemetry_collector_xray" {
  role       = aws_iam_role.opentelemetry_collector.id
  policy_arn = "${local.policy_arn_prefix}/AWSXRayDaemonWriteAccess"
}

resource "aws_eks_pod_identity_association" "opentelemetry_collector" {
  cluster_name    = var.eks_cluster_name
  role_arn        = aws_iam_role.opentelemetry_collector.arn
  namespace       = "o11y"
  service_account = "otel-collector"
}
