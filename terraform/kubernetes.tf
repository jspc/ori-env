// Spin up a kubernetes cluster for our
// tech-test app

locals {
  ori_sub  = "ori"
  ori_fqdn = "${local.ori_sub}.${var.domain}"

  ori_droplet_tag_raw = "k8s:worker:${local.ori_fqdn}"
  ori_droplet_tag     = "tf:${sha256(local.ori_droplet_tag_raw)}"
}

module "config_bucket" {
  source = "./modules/spaces"
  fqdn   = "config.${local.ori_fqdn}"
  acl    = "private"
}

resource "digitalocean_kubernetes_cluster" "orico" {
  name    = "${local.ori_sub}"
  region  = "nyc3"
  version = "1.14.4-do.0"
  tags    = ["tech-test", "ori-co"]

  node_pool {
    name       = "nodes"
    size       = "s-2vcpu-2gb"
    node_count = 3
    tags       = ["${local.ori_droplet_tag}"]
  }
}

resource "aws_s3_bucket_object" "kubeconfig" {
  bucket  = "${module.config_bucket.name}"
  key     = "kubeconfig"
  content = "${digitalocean_kubernetes_cluster.orico.kube_config.0.raw_config}"

  depends_on = ["module.config_bucket"]
}

resource "digitalocean_certificate" "kubernetes" {
  name    = "${local.ori_fqdn}"
  type    = "lets_encrypt"
  domains = ["${local.ori_fqdn}", "monitoring.${local.ori_fqdn}", "sine.${local.ori_fqdn}"]

  lifecycle {
    create_before_destroy = true
  }
}

resource "digitalocean_loadbalancer" "public" {
  name   = "${local.ori_fqdn}"
  region = "nyc3"

  forwarding_rule {
    entry_port     = 443
    entry_protocol = "https"

    target_port     = 32443
    target_protocol = "https"

    certificate_id = "${digitalocean_certificate.kubernetes.id}"
  }

  redirect_http_to_https = true

  healthcheck {
    port     = 32080
    protocol = "tcp"
  }

  droplet_tag = "${local.ori_droplet_tag}"
}

data "digitalocean_domain" "domain" {
  name = "${var.domain}"
}

resource "digitalocean_record" "orico" {
  domain = "${data.digitalocean_domain.domain.name}"
  type   = "A"
  name   = "${local.ori_sub}"
  value  = "${digitalocean_loadbalancer.public.ip}"
}

resource "digitalocean_record" "monitoring" {
  domain = "${data.digitalocean_domain.domain.name}"
  type   = "A"
  name   = "monitoring.${local.ori_sub}"
  value  = "${digitalocean_loadbalancer.public.ip}"
}

resource "digitalocean_record" "sine" {
  domain = "${data.digitalocean_domain.domain.name}"
  type   = "A"
  name   = "sine.${local.ori_sub}"
  value  = "${digitalocean_loadbalancer.public.ip}"
}
