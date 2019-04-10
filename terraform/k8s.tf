module "network" {
  source = "./modules/network"

  project = "${var.project}"
  stage   = "${var.stage}"

  vpc_cidr_block     = "10.0.0.0/16"
  availability_zones = "us-east-1a,us-east-1b,us-east-1c"
  public_subnets     = "10.0.1.0/24,10.0.3.0/24,10.0.5.0/24"
  private_subnets    = "10.0.2.0/24,10.0.4.0/24,10.0.6.0/24"
}

module "eks-cluster" {
  source = "./modules/eks-cluster"

  project = "${var.project}"
  stage   = "${var.stage}"

  vpc_id     = "${module.network.vpc_id}"
  subnet_ids = "${split(",", module.network.public_subnet_ids)}" # TODO maybe consider to add also the private subnets

  additional_security_groups = []
  additional_cidr_blocks     = ["0.0.0.0/0"]

  k8s_version           = "1.12"
  enable_private_access = true
  enable_public_access  = true
}

module "eks-workers-default" {
  source = "./modules/eks-workers"

  project  = "${var.project}"
  stage    = "${var.stage}"
  asg_type = "default"

  eks_cluster_name                       = "${module.eks-cluster.cluster_eks_name}"
  eks_cluster_endpoint                   = "${module.eks-cluster.cluster_eks_endpoint}"
  eks_cluster_certificate_authority_data = "${module.eks-cluster.cluster_certificate_authority_data}"
  eks_cluster_security_group_id          = "${module.eks-cluster.cluster_eks_sg_id}"

  min_size      = 1
  max_size      = 3
  instance_type = "t3.small"

  # pick the right image from here: https://docs.aws.amazon.com/eks/latest/userguide/eks-optimized-ami.html
  image_id = "ami-0abcb9f9190e867ab"

  vpc_id     = "${module.network.vpc_id}"
  subnet_ids = "${split(",", module.network.public_subnet_ids)}"
}

data "aws_iam_policy_document" "workers_default_iam_policy_extension" {
  statement {
    effect    = "Allow"
    actions   = ["s3:Get*"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "workers_default_iam_role_extension" {
  policy = "${data.aws_iam_policy_document.workers_default_iam_policy_extension.json}"
  role   = "${module.eks-workers-default.worker_role_id}"
}