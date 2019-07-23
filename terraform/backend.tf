provider "digitalocean" {
  version = "~> 1.5"

  token             = "${var.do_token}"
  spaces_access_id  = "${var.spaces_access_key}"
  spaces_secret_key = "${var.spaces_secret_key}"
}

// Because digital ocean spaces, where we want to store our kubeconfig,
// is an s3 clone we can use aws_s3_bucket_object, from the aws provider,
// to upload, provided we set the correct endpoint URL
provider "aws" {
  version = "~> 2.20"

  region     = "us-east-1" // this is ignored
  access_key = "${var.spaces_access_key}"
  secret_key = "${var.spaces_secret_key}"

  skip_credentials_validation = true
  skip_get_ec2_platforms      = true
  skip_region_validation      = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    s3 = "https://nyc3.digitaloceanspaces.com"
  }
}
