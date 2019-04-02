module "network" {
  source                = "./modules/network"

  project               = "${var.project}"
  stage                 = "${var.stage}"

  vpc_cidr_block        = "10.0.0.0/16"
  availability_zones    = "us-east-1a,us-east-1b,us-east-1c"
  public_subnets        = "10.0.1.0/24,10.0.3.0/24,10.0.5.0/24"
  private_subnets       = "10.0.2.0/24,10.0.4.0/24,10.0.6.0/24"
}
