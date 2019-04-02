module "network" {
  source                = "./modules/network"

  project               = "${var.project}"
  stage                 = "${var.stage}"

  vpc_cidr_block        = "10.0.0.0/16"
  availability_zones    = "us-east-1a,us-east-1b,us-east-1c"
  public_subnets        = "10.0.1.0/24,10.0.3.0/24,10.0.5.0/24"
  private_subnets       = "10.0.2.0/24,10.0.4.0/24,10.0.6.0/24"
}

module "eks-cluster" {
  source                = "./modules/eks-cluster"
  
  project               = "${var.project}"
  stage                 = "${var.stage}"

  vpc_id                = "${module.network.vpc_id}"
  subnet_ids            = "${split(",", module.network.public_subnet_ids)}"

  workers_security_group_ids = []
  additional_security_groups = []
  additional_cidr_blocks = ["0.0.0.0/0"]

  k8s_version           = "1.12"
  enable_private_access = true
  enable_public_access  = true
}
