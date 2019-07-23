// Configure digital ocean provider
//
// See: https://www.terraform.io/docs/providers/do/index.html

variable "do_token" {}

variable "spaces_access_key" {}
variable "spaces_secret_key" {}

variable "domain" {
  description = "Domain name to configure cluster under"
  default     = "jspc.pw"
}
