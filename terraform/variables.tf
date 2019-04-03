variable "aws_region" {
  default = "us-east-1"
}

variable "project" {
  default = "nicor88"
}

variable "stage" {
  default = "dev"
}

variable "s3_state_bucket" {
  default = "nicola-corda-terraform"
}

variable "s3_state_file" {
  default = "dev/k8s/state.tfstate"
}
