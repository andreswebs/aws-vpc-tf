data "aws_acm_certificate" "this" {
  domain = var.domain_name
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
