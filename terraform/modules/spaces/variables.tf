variable "fqdn" {
  description = "Fully qualified domain name to use when configuring space/ cert/ cdn"
  default     = "hello.jspc.pw"
}

variable "acl" {
  description = "Digital Ocean Spaces canned acl. See: https://www.terraform.io/docs/providers/do/r/spaces_bucket.html#acl"
  default     = "public-read"
}
