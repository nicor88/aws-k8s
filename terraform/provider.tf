provider "aws" {
  region = "${var.aws_region}"
  version = "2.4.0"
}

terraform {
  required_version = ">= 0.11.7"
  backend "s3" {}
}

data "terraform_remote_state" "s3_remote_state" {
  backend = "s3"

  config {
    bucket = "${var.s3_state_bucket}"
    key    = "${var.stage}/${var.project}/state.tfstate}"
    region = "${var.aws_region}"
  }
}
