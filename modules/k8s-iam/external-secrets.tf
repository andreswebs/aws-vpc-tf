resource "aws_iam_role" "external_secrets" {
  name = "external-secrets-${var.eks_cluster_name}"

  assume_role_policy    = data.aws_iam_policy_document.pods_trust.json
  force_detach_policies = true
  tags                  = var.tags
}

module "iam_policy_external_secrets_ssm_access" {
  count           = length(var.allowed_parameter_names) > 0 ? 1 : 0
  source          = "andreswebs/ssm-parameters-access-policy-document/aws"
  version         = "1.5.0"
  parameter_names = var.allowed_parameter_names
}

module "iam_policy_external_secrets_sm_access" {
  count        = length(var.allowed_secret_names) > 0 ? 1 : 0
  source       = "andreswebs/secrets-access-policy-document/aws"
  version      = "1.6.0"
  secret_names = var.allowed_secret_names
}

data "aws_iam_policy_document" "external_secrets_ecr_access" {
  statement {
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:GetAuthorizationToken",
      "ecr:GetDownloadUrlForLayer",
      "ecr:ListImages",
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "external_secrets" {
  source_policy_documents = compact([
    try(module.iam_policy_external_secrets_ssm_access[0].json, null),
    try(module.iam_policy_external_secrets_sm_access[0].json, null),
    data.aws_iam_policy_document.external_secrets_ecr_access.json,
  ])
}

resource "aws_iam_role_policy" "external_secrets" {
  name   = "external-secrets-permissions"
  role   = aws_iam_role.external_secrets.id
  policy = data.aws_iam_policy_document.external_secrets.json
}

resource "aws_eks_pod_identity_association" "external_secrets" {
  cluster_name    = var.eks_cluster_name
  role_arn        = aws_iam_role.external_secrets.arn
  namespace       = "external-secrets"
  service_account = "external-secrets"
}
