// Configure everything necessary to put a bucket behind
// a cdn

locals {
  bucket = "${replace(var.fqdn, ".", "-")}"
}

resource "digitalocean_spaces_bucket" "bucket" {
  name   = "${local.bucket}"
  region = "nyc3"
  acl    = "${var.acl}"
}

resource "digitalocean_certificate" "cert" {
  name    = "c.${var.fqdn}"
  type    = "lets_encrypt"
  domains = ["jspc.pw", "${var.fqdn}"]

  depends_on = ["digitalocean_spaces_bucket.bucket"]
}

resource "digitalocean_cdn" "cdn" {
  origin         = "${digitalocean_spaces_bucket.bucket.bucket_domain_name}"
  custom_domain  = "${var.fqdn}"
  certificate_id = "${digitalocean_certificate.cert.id}"
}
