variable "project" {}

variable "stage" {}

variable "eks_cluster_name" {}

variable "eks_cluster_endpoint" {}

variable "eks_cluster_certificate_authority_data" {}

variable "eks_bootstrap_extra_args" {
  type        = "string"
  default     = ""
  description = "Passed to the bootstrap.sh script to enable --kublet-extra-args or --use-max-pods."
}

variable "eks_cluster_security_group_id" {}

variable "asg_type" {
  type    = "string"
  default = "default"
}

variable "vpc_id" {
  type        = "string"
  description = "VPC ID for the EKS cluster"
}

variable "additional_sg_allowed" {
  type        = "list"
  default     = []
  description = "List of Security Group IDs to be allowed to connect to the worker nodes"
}

variable "additional_cidr_allowed" {
  type        = "list"
  default     = []
  description = "List of CIDR blocks to be allowed to connect to the worker nodes"
}

variable "image_id" {
  type        = "string"
  description = "AMI to use to run EKS"
}

variable "instance_type" {
  type        = "string"
  description = "AMI to use to run EKS"
}

variable "enable_monitoring" {
  description = "Enable/disable detailed monitoring"
  default     = true
}

variable "key_name" {
  type    = "string"
  default = ""
}

variable "associate_public_ip_address" {
  description = "Associate a public IP address with an instance in a VPC"
  default     = false
}

variable "credit_specification" {
  description = "Customize the credit specification of the instances"
  type        = "list"
  default     = []
}

variable "elastic_gpu_specifications" {
  description = "Specifications of Elastic GPU to attach to the instances"
  type        = "list"
  default     = []
}

variable "ebs_optimized" {
  description = "If true, the launched EC2 instance will be EBS-optimized"
  default     = true
}

variable "ebs_size_gb" {
  description = "size in GB of EBS volume"
  default = 20
}

variable "ebs_device_name" {
  description = "EBS mounting point name"
  default = "/dev/xvda"
}

variable "ebs_type" {
  description = "EBS type"
  default = "standard"
}

variable "disable_api_termination" {
  description = "If `true`, enables EC2 Instance Termination Protection"
  default     = false
}

variable "instance_initiated_shutdown_behavior" {
  type        = "string"
  description = "Shutdown behavior for the instances. Can be `stop` or `terminate`"
  default     = "terminate"
}

variable "placement" {
  description = "The placement specifications of the instances"
  type        = "list"
  default     = []
}

variable "block_device_mappings" {
  description = "Specify volumes to attach to the instance besides the volumes specified by the AMI"
  type        = "list"
  default     = []
}

variable "instance_market_options" {
  description = "The market (purchasing) option for the instances"
  type        = "list"
  default     = []
}

variable "min_size" {}

variable "max_size" {}

variable "subnet_ids" {
  description = "A list of subnet IDs to launch resources in"
  type        = "list"
}

variable "load_balancers" {
  type        = "list"
  description = "A list of elastic load balancer names to add to the autoscaling group names. Only valid for classic load balancers. For ALBs, use `target_group_arns` instead"
  default     = []
}

variable "health_check_grace_period" {
  description = "Time (in seconds) after instance comes into service before checking health"
  default     = 300
}

variable "health_check_type" {
  type        = "string"
  description = "Controls how health checking is done. Valid values are `EC2` or `ELB`"
  default     = "EC2"
}

variable "min_elb_capacity" {
  description = "Setting this causes Terraform to wait for this number of instances to show up healthy in the ELB only on creation. Updates will not wait on ELB instance number changes"
  default     = 0
}

variable "wait_for_elb_capacity" {
  description = "Setting this will cause Terraform to wait for exactly this number of healthy instances in all attached load balancers on both create and update operations. Takes precedence over `min_elb_capacity` behavior"
  default     = false
}

variable "target_group_arns" {
  type        = "list"
  description = "A list of aws_alb_target_group ARNs, for use with Application Load Balancing"
  default     = []
}

variable "termination_policies" {
  description = "A list of policies to decide how the instances in the auto scale group should be terminated. The allowed values are `OldestInstance`, `NewestInstance`, `OldestLaunchConfiguration`, `ClosestToNextInstanceHour`, `Default`"
  type        = "list"
  default     = ["Default"]
}

variable "suspended_processes" {
  type        = "list"
  description = "A list of processes to suspend for the AutoScaling Group. The allowed values are `Launch`, `Terminate`, `HealthCheck`, `ReplaceUnhealthy`, `AZRebalance`, `AlarmNotification`, `ScheduledActions`, `AddToLoadBalancer`. Note that if you suspend either the `Launch` or `Terminate` process types, it can prevent your autoscaling group from functioning properly."
  default     = []
}

variable "placement_group" {
  type        = "string"
  description = "The name of the placement group into which you'll launch your instances, if any"
  default     = ""
}

variable "metrics_granularity" {
  type        = "string"
  description = "The granularity to associate with the metrics to collect. The only valid value is 1Minute"
  default     = "1Minute"
}

variable "default_cooldown" {
  description = "The amount of time, in seconds, after a scaling activity completes before another scaling activity can start"
  default     = 300
}

variable "force_delete" {
  description = "Allows deleting the autoscaling group without waiting for all instances in the pool to terminate. You can force an autoscaling group to delete even if it's in the process of scaling a resource. Normally, Terraform drains all the instances before deleting the group. This bypasses that behavior and potentially leaves resources dangling"
  default     = false
}

variable "enabled_metrics" {
  description = "A list of metrics to collect. The allowed values are `GroupMinSize`, `GroupMaxSize`, `GroupDesiredCapacity`, `GroupInServiceInstances`, `GroupPendingInstances`, `GroupStandbyInstances`, `GroupTerminatingInstances`, `GroupTotalInstances`"
  type        = "list"

  default = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]
}

variable "wait_for_capacity_timeout" {
  type        = "string"
  description = "A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. Setting this to '0' causes Terraform to skip all Capacity Waiting behavior"
  default     = "10m"
}

variable "protect_from_scale_in" {
  description = "Allows setting instance protection. The autoscaling group will not select instances with this setting for terminination during scale in events"
  default     = false
}

variable "service_linked_role_arn" {
  type        = "string"
  description = "The ARN of the service-linked role that the ASG will use to call other AWS services"
  default     = ""
}
