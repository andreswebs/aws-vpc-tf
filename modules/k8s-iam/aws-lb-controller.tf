resource "aws_iam_role" "lb_controller" {
  name = "lb-controller-${var.eks_cluster_name}"

  assume_role_policy    = data.aws_iam_policy_document.pods_trust.json
  force_detach_policies = true
  tags                  = var.tags
}

resource "aws_iam_role_policy" "lb_controller" {
  name   = "lb-controller-permissions"
  role   = aws_iam_role.lb_controller.id
  policy = file("${path.module}/tpl/aws-load-balancer-controller.json")
}

resource "aws_eks_pod_identity_association" "lb_controller" {
  cluster_name    = var.eks_cluster_name
  role_arn        = aws_iam_role.lb_controller.arn
  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller"
}
