module "network" {
  source = "./modules/network"

  project = "${var.project}"
  stage   = "${var.stage}"

  vpc_cidr_block     = "10.0.0.0/16"
  availability_zones = "us-east-1a,us-east-1b,us-east-1c"
  public_subnets     = "10.0.1.0/24,10.0.3.0/24,10.0.5.0/24"
  private_subnets    = "10.0.2.0/24,10.0.4.0/24,10.0.6.0/24"

  eks_cluster_name = "${var.project}-${var.stage}-k8s-cluster"
}

module "eks_cluster" {
  source = "./modules/eks-cluster"

  project = "${var.project}"
  stage   = "${var.stage}"

  vpc_id = "${module.network.vpc_id}"

  subnet_ids = "${concat(
    "${split(",", module.network.public_subnet_ids)}",
    "${split(",", module.network.private_subnet_ids)}"
    )}"

  additional_security_groups = []
  additional_cidr_blocks     = ["0.0.0.0/0"]

  k8s_version           = "1.12"
  enable_private_access = true
  enable_public_access  = true
}

module "eks_workers_default" {
  source = "./modules/eks-workers"

  project  = "${var.project}"
  stage    = "${var.stage}"
  asg_type = "default"

  eks_cluster_name                       = "${module.eks_cluster.cluster_eks_name}"
  eks_cluster_endpoint                   = "${module.eks_cluster.cluster_eks_endpoint}"
  eks_cluster_certificate_authority_data = "${module.eks_cluster.cluster_certificate_authority_data}"
  eks_cluster_security_group_id          = "${module.eks_cluster.cluster_eks_sg_id}"

  min_size      = 2
  max_size      = 4
  instance_type = "t3.medium"
  ebs_size_gb   = 50
  ebs_type      = "gp2"

  # pick the right image from here: https://docs.aws.amazon.com/eks/latest/userguide/eks-optimized-ami.html
  image_id = "ami-0abcb9f9190e867ab" # strictly dependent on the EKS version

  vpc_id     = "${module.network.vpc_id}"
  subnet_ids = "${split(",", module.network.private_subnet_ids)}"
}

data "aws_iam_policy_document" "workers_default_iam_policy_extension" {
  # TODO refine this policy, split reads from writey
  statement {
    effect    = "Allow"
    actions   = ["s3:*"]
    resources = ["*"]
  }

  // Following statement allow the cluster autoscaler
  statement {
    effect = "Allow"
    actions = [
      "autoscaling:Describe*",
    ]
    resources = [
      "*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
    ]

    resources = [
      "${module.eks_workers_default.autoscaling_group_arn}",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "ec2:DescribeAccountAttributes",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_role_policy" "workers_default_iam_role_extension" {
  policy = "${data.aws_iam_policy_document.workers_default_iam_policy_extension.json}"
  role   = "${module.eks_workers_default.worker_role_id}"
}
