// Configure everything necessary to host helm charts in
// digital ocean spaces

locals {
  charts_fqdn = "charts.${var.domain}"
}

module "helm_bucket" {
  source = "./modules/spaces"
  fqdn   = "${local.charts_fqdn}"
}
