locals {
  cluster_name = "${var.project}-${var.stage}-k8s-cluster"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals = {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = "${local.cluster_name}-role"
  assume_role_policy = "${join("", data.aws_iam_policy_document.assume_role.*.json)}"
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.this.name}"
}

resource "aws_iam_role_policy_attachment" "eks_service_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.this.name}"
}

resource "aws_security_group" "this" {
  name        = "${local.cluster_name}-sg"
  description = "Security Group for EKS cluster"
  vpc_id      = "${var.vpc_id}"

  tags = {
    Name  = "${local.cluster_name}-sg"
    Stage = "${var.stage}"
  }
}

resource "aws_security_group_rule" "egress" {
  description       = "Allow all egress traffic"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.this.id}"
  type              = "egress"
}

resource "aws_security_group_rule" "additional_sgs" {
  count                    = "${length(var.additional_security_groups) > 0 ? length(var.additional_security_groups) : 0}"
  description              = "Allow additional security groups to communicate with the cluster"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  source_security_group_id = "${element(var.additional_security_groups, count.index)}"
  security_group_id        = "${aws_security_group.this.id}"
  type                     = "ingress"
}

resource "aws_security_group_rule" "ingress_cidr_blocks" {
  count             = "${length(var.additional_cidr_blocks) > 0 ? 1 : 0}"
  security_group_id = "${aws_security_group.this.id}"
  type              = "ingress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 65535
  cidr_blocks       = ["${var.additional_cidr_blocks}"]
  description       = "Allow inbound traffic from CIDR blocks"
}

resource "aws_eks_cluster" "this" {
  name     = "${local.cluster_name}"
  role_arn = "${aws_iam_role.this.arn}"
  version  = "${var.k8s_version}"

  vpc_config {
    security_group_ids      = ["${aws_security_group.this.id}"]
    subnet_ids              = ["${var.subnet_ids}"]
    endpoint_private_access = "${var.enable_private_access}"
    endpoint_public_access  = "${var.enable_public_access}"
  }

  depends_on = [
    "aws_iam_role_policy_attachment.eks_cluster_policy",
    "aws_iam_role_policy_attachment.eks_service_policy",
  ]
}
