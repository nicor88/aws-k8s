locals {
  eks_workers = "${var.project}-${var.stage}-${var.asg_type}-k8s-workers"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals = {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = "${local.eks_workers}-role"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role.json}"
}

resource "aws_iam_role_policy_attachment" "aws_eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.this.name}"
}

resource "aws_iam_role_policy_attachment" "aws_eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${aws_iam_role.this.name}"
}

resource "aws_iam_role_policy_attachment" "aws_ec2_container_registry_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.this.name}"
}

resource "aws_iam_instance_profile" "this" {
  name = "${local.eks_workers}-instance-profile"
  role = "${aws_iam_role.this.name}"
}

resource "aws_security_group" "this" {
  name        = "${local.eks_workers}-sg"
  vpc_id      = "${var.vpc_id}"
  description = "Security Group for EKS worker nodes"

  tags = "${
    map(
     "Project", "${var.project}",
     "Stage", "${var.stage}",
     "Name", "${local.eks_workers}-sg",
     "kubernetes.io/cluster/${var.eks_cluster_name}", "owned"
    )
  }"
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

resource "aws_security_group_rule" "ingress_self" {
  description              = "Allow nodes to communicate with each other"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.this.id}"
  source_security_group_id = "${aws_security_group.this.id}"
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks_cluster_workers_sgs" {
  description              = "Allow the cluster to receive communication from the worker nodes"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = "${var.eks_cluster_security_group_id}"
  source_security_group_id = "${aws_security_group.this.id}"
  type                     = "ingress"
}

resource "aws_security_group_rule" "ingress_cluster" {
  description              = "Allow worker kubelets and pods to receive communication from the cluster control plane"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.this.id}"
  source_security_group_id = "${var.eks_cluster_security_group_id}"
  type                     = "ingress"
}

resource "aws_security_group_rule" "ingress_security_groups" {
  count                    = "${length(var.additional_sg_allowed) > 0 ? length(var.additional_sg_allowed) : 0}"
  description              = "Allow inbound traffic from existing Security Groups"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  source_security_group_id = "${element(var.additional_sg_allowed, count.index)}"
  security_group_id        = "${aws_security_group.this.id}"
  type                     = "ingress"
}

resource "aws_security_group_rule" "ingress_cidr_blocks" {
  count             = "${length(var.additional_cidr_allowed) > 0 ? 1 : 0}"
  description       = "Allow inbound traffic from CIDR blocks"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["${var.additional_cidr_allowed}"]
  security_group_id = "${aws_security_group.this.id}"
  type              = "ingress"
}

data "template_file" "userdata" {
  template = "${file("${path.module}/userdata.tpl")}"

  vars {
    cluster_endpoint           = "${var.eks_cluster_endpoint}"
    certificate_authority_data = "${var.eks_cluster_certificate_authority_data}"
    cluster_name               = "${var.eks_cluster_name}"
    bootstrap_extra_args       = "${var.eks_bootstrap_extra_args}"
  }
}

resource "aws_launch_template" "this" {
  name_prefix                          = "${local.eks_workers}"
  block_device_mappings                = ["${var.block_device_mappings}"]
  credit_specification                 = ["${var.credit_specification}"]
  disable_api_termination              = "${var.disable_api_termination}"
  ebs_optimized                        = "${var.ebs_optimized}"
  elastic_gpu_specifications           = ["${var.elastic_gpu_specifications}"]
  image_id                             = "${var.image_id}"
  instance_initiated_shutdown_behavior = "${var.instance_initiated_shutdown_behavior}"
  instance_market_options              = ["${var.instance_market_options }"]
  instance_type                        = "${var.instance_type}"
  key_name                             = "${var.key_name}"
  placement                            = ["${var.placement}"]
  user_data                            = "${base64encode(join("", data.template_file.userdata.*.rendered))}"

  iam_instance_profile {
    name = "${aws_iam_instance_profile.this.name}"
  }

  monitoring {
    enabled = "${var.enable_monitoring}"
  }

  # https://github.com/terraform-providers/terraform-provider-aws/issues/4570
  network_interfaces {
    description                 = "ENI belonging to Autoscaling Group ${local.eks_workers}"
    device_index                = 0
    associate_public_ip_address = "${var.associate_public_ip_address}"
    delete_on_termination       = true
    security_groups             = ["${aws_security_group.this.id}"]
  }

  tag_specifications {
    resource_type = "volume"

    tags = "${
      map(
       "Project", "${var.project}",
       "Stage", "${var.stage}",
       "Name", "${local.eks_workers}-volume",
       "kubernetes.io/cluster/${var.eks_cluster_name}", "owned"
      )
    }"
  }

  tag_specifications {
    resource_type = "instance"

    tags = "${
      map(
       "Project", "${var.project}",
       "Stage", "${var.stage}",
       "Name", "${local.eks_workers}-instance",
       "kubernetes.io/cluster/${var.eks_cluster_name}", "owned"
      )
    }"
  }

  tags = "${
      map(
       "Project", "${var.project}",
       "Stage", "${var.stage}",
       "Name", "${local.eks_workers}-instance",
       "kubernetes.io/cluster/${var.eks_cluster_name}", "owned"
      )
    }"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "this" {
  name_prefix               = "${local.eks_workers}"
  vpc_zone_identifier       = ["${var.subnet_ids}"]
  max_size                  = "${var.max_size}"
  min_size                  = "${var.min_size}"
  load_balancers            = ["${var.load_balancers}"]
  health_check_grace_period = "${var.health_check_grace_period}"
  health_check_type         = "${var.health_check_type}"
  min_elb_capacity          = "${var.min_elb_capacity}"
  wait_for_elb_capacity     = "${var.wait_for_elb_capacity}"
  target_group_arns         = ["${var.target_group_arns}"]
  default_cooldown          = "${var.default_cooldown}"
  force_delete              = "${var.force_delete}"
  termination_policies      = "${var.termination_policies}"
  suspended_processes       = "${var.suspended_processes}"
  placement_group           = "${var.placement_group}"
  enabled_metrics           = ["${var.enabled_metrics}"]
  metrics_granularity       = "${var.metrics_granularity}"
  wait_for_capacity_timeout = "${var.wait_for_capacity_timeout}"
  protect_from_scale_in     = "${var.protect_from_scale_in}"
  service_linked_role_arn   = "${var.service_linked_role_arn}"

  launch_template = {
    id      = "${join("", aws_launch_template.this.*.id)}"
    version = "${aws_launch_template.this.latest_version}"
  }

  tag {
    key                 = "Project"
    value               = "${var.project}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Stage"
    value               = "${var.stage}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = "${local.eks_workers}-asg"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.eks_cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
