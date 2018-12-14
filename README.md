# aws-k8s
Run kubernetes(k8s) inside AWS

There are multiple ways to run Kubernetes on AWS, one of this based on using [EKS](https://aws.amazon.com/eks/).

In this repository you can find multiple ways how deploy K8S based on EKS

## Requirements
* [awscli](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html)
* [kubectl](https://docs.aws.amazon.com/eks/latest/userguide/configure-kubectl.html)
* [heptio-authenticator-aws](https://docs.aws.amazon.com/eks/latest/userguide/configure-kubectl.html) (check the section **To install heptio-authenticator-aws for Amazon EKS**)


## Deployment with Cloudformation

1. Create the Master Node stack
	<pre>
	bash cloudformation/create_master_stack.sh
	</pre>

2. Create the Master Node stack
	<pre>
	bash cloudformation/create_master_stack.sh
	</pre>

3. Retrieve EKS Cluster information
	<pre>
	aws eks describe-cluster --name dev --query cluster.endpoint
	aws eks describe-cluster --name dev --query cluster.certificateAuthority.data
	</pre>
