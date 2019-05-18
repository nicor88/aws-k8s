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

output "autoscaling_group_id" {
  description = "The autoscaling group id"
  value       = "${aws_autoscaling_group.this.id}"
}

output "autoscaling_group_name" {
  description = "The autoscaling group name"
  value       = "${aws_autoscaling_group.this.name}"
}

output "autoscaling_group_arn" {
  description = "ARN of the AutoScaling Group"
  value       = "${aws_autoscaling_group.this.arn}"
}

output "autoscaling_group_min_size" {
  description = "The minimum size of the autoscale group"
  value       = "${aws_autoscaling_group.this.min_size}"
}

output "autoscaling_group_max_size" {
  description = "The maximum size of the autoscale group"
  value       = "${aws_autoscaling_group.this.max_size}"
}

output "autoscaling_group_desired_capacity" {
  description = "The number of Amazon EC2 instances that should be running in the group"
  value       = "${aws_autoscaling_group.this.desired_capacity}"
}

output "autoscaling_group_default_cooldown" {
  description = "Time between a scaling activity and the succeeding scaling activity"
  value       = "${aws_autoscaling_group.this.default_cooldown}"
}

output "autoscaling_group_health_check_grace_period" {
  description = "Time after instance comes into service before checking health"
  value       = "${aws_autoscaling_group.this.health_check_grace_period}"
}

output "autoscaling_group_health_check_type" {
  description = "`EC2` or `ELB`. Controls how health checking is done"
  value       = "${aws_autoscaling_group.this.health_check_type}"
}
