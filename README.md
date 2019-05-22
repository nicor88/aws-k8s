# aws-k8s
Run kubernetes(k8s) inside AWS

There are multiple ways to run Kubernetes on AWS, one of this based on using [EKS](https://aws.amazon.com/eks/).

In this repository you can find multiple ways how deploy K8S based on EKS

## Requirements
* [awscli](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html)
* [kubectl](https://docs.aws.amazon.com/eks/latest/userguide/configure-kubectl.html)
* [heptio-authenticator-aws](https://docs.aws.amazon.com/eks/latest/userguide/configure-kubectl.html) (check the section **To install heptio-authenticator-aws for Amazon EKS**)


## Deployment with Cloudformation

Create all needed resources running
<pre>
cd cloudformation
bash setup_all.sh
</pre>

This command will setup:
* the Master Cloudformation stack containing EKS and all the needed Network resources
* the Worker Cloudformation stack containing an autoscaling group
* create a kubectl config file
* apply the node authentication to enable the EC2 machines to join K8S


## Deployment with Terraform

<pre>
export AWS_PROFILE=your_profile
cd terraform
make init
make plan
make apply
</pre>

After the deployment is done, you need to apply the `k8s/config_map.dist.yml`.
Run the following:
<pre>
cp k8s/config_map.dist.yml k8s/config_map.yml
</pre>

Be sure to replace `REPLACE_WITH_ARN_INSTANCE_PROFILE_ROLE` with the right role ARN.
Before applying the following yml file to the cluster, be sure to have `kubectl` installed and configured to the just created cluster.


## Setup Local config
* Install [awscli](https://docs.aws.amazon.com/cli/latest/userguide/install-macos.html)
* Run the following command:
<pre>
export AWS_PROFILE=your_profile
aws eks update-kubeconfig --name nicor88-dev-k8s-cluster --kubeconfig ~/.kube/config_nicor88-dev-k8s-cluster
export KUBECONFIG=~/.kube/config_nicor88-dev-k8s-cluster
</pre>

## Plugins
The folder **monitoring** includes all the needed configuration files to deploy a nice K8S Dashboard to check containers status.
<pre>
kube apply -f plugins/monitoring/ --recursive
</pre>

## Notes
* All the following resources are based on the official AWS Documentation.
