output "security_group_id" {
  description = "ID of the worker nodes Security Group"
  value       = "${aws_security_group.this.id}"
}

output "security_group_arn" {
  description = "ARN of the worker nodes Security Group"
  value       = "${aws_security_group.this.arn}"
}

output "security_group_name" {
  description = "Name of the worker nodes Security Group"
  value       = "${aws_security_group.this.name}"
}

output "worker_role_arn" {
  description = "ARN of the worker nodes IAM role"
  value       = "${aws_iam_role.this.arn}"
}

output "worker_role_id" {
  description = "ARN of the worker nodes IAM role"
  value       = "${aws_iam_role.this.id}"
}

output "worker_role_name" {
  description = "ARN of the worker nodes IAM role"
  value       = "${aws_iam_role.this.name}"
}
