locals {
  argocd_domain_name = "${var.argocd_subdomain}.${var.domain_name}"
  target_cluster     = 1
  select_tg          = local.target_cluster - 1
}

data "aws_acm_certificate" "this" {
  domain = var.domain_name
}

data "aws_route53_zone" "this" {
  name = "${var.domain_name}."
}

module "network" {
  source     = "andreswebs/vpc/aws"
  version    = "0.0.4"
  name       = var.network_name
  cidr_block = var.network_cidr_ipv4

  private_subnet_cidr_blocks = var.private_subnet_cidrs_ipv4
  public_subnet_cidr_blocks  = var.public_subnet_cidrs_ipv4

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }
}

module "web_alb" {
  source               = "../../modules/web-alb"
  name                 = var.network_name
  public_subnet_ids    = module.network.public_subnet_ids
  acm_certificate_arns = [data.aws_acm_certificate.this.arn]
}

resource "aws_route53_record" "argocd" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = local.argocd_domain_name
  type    = "A"

  alias {
    name                   = module.web_alb.lb.dns_name
    zone_id                = module.web_alb.lb.zone_id
    evaluate_target_health = true
  }
}

module "web_target_argocd_grpc" {
  source           = "../../modules/lb-target-pair"
  name             = "argocd-grpc-andre-example"
  vpc_id           = module.network.vpc.id
  protocol         = "HTTPS"
  protocol_version = "GRPC"
  target_port      = 8080

  health_check = {
    protocol = "HTTPS"
    path     = "/AWS.ALB/healthcheck"
    matcher  = "12"
  }
}

resource "aws_lb_listener_rule" "argocd_grpc" {
  listener_arn = module.web_alb.listener.https.arn
  priority     = 1000

  action {
    type             = "forward"
    target_group_arn = module.web_target_argocd_grpc.target_group[local.select_tg].arn
  }

  condition {
    host_header {
      values = [local.argocd_domain_name]
    }
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }

  condition {
    http_header {
      http_header_name = "Content-Type"
      values           = ["application/grpc"]
    }
  }
}

module "web_target_argocd_https" {
  source      = "../../modules/lb-target-pair"
  name        = "argocd-andre-example"
  vpc_id      = module.network.vpc.id
  protocol    = "HTTPS"
  target_port = 8080

  health_check = {
    protocol = "HTTPS"
  }
}

resource "aws_lb_listener_rule" "argocd_https" {
  listener_arn = module.web_alb.listener.https.arn
  priority     = 1001

  action {
    type             = "forward"
    target_group_arn = module.web_target_argocd_https.target_group[local.select_tg].arn
  }

  condition {
    host_header {
      values = [local.argocd_domain_name]
    }
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}
