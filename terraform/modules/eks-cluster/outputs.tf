// IAM Role

output "this_aws_iam_role_name" {
  value = "${aws_iam_role.this.name}"
}

output "this_aws_iam_role_id" {
  value = "${aws_iam_role.this.id}"
}

output "this_aws_iam_role_arn" {
  value = "${aws_iam_role.this.arn}"
}

// Security Group

output "cluster_eks_sg_id" {
  value = "${aws_security_group.this.id}"
}

// Cluster

output "cluster_eks_id" {
  value = "${aws_eks_cluster.this.id}"
}

output "cluster_eks_name" {
  value = "${aws_eks_cluster.this.name}"
}

output "cluster_eks_arn" {
  value = "${aws_eks_cluster.this.arn}"
}

output "cluster_eks_endpoint" {
  value = "${aws_eks_cluster.this.endpoint}"
}

output "cluster_eks_role_arn" {
  value = "${aws_eks_cluster.this.role_arn}"
}

output "cluster_certificate_authority_data" {
  value = "${aws_eks_cluster.this.certificate_authority.0.data}"
}
