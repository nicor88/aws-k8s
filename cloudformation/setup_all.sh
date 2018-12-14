#!/bin/sh
set -e

if [ -z "$AWS_DEFAULT_PROFILE" ]; then
    echo "Please set the AWS_DEFAULT_PROFILE environment variable"
    exit 1
fi

# setup
CLUSTER_NAME="dev"
ARN_USER=$(aws sts get-caller-identity --output text --query 'Arn')
IAM_USER=$(echo $ARN_USER | cut -d "/" -f2)

echo "Creating the cluster from user $IAM_USER"

# master
MASTER_STACK_NAME="$CLUSTER_NAME-k8s-master"
MASTER_TEMPLATE_URL="file://master.yml"

echo 'Checking master template validity'
aws cloudformation validate-template --template-body $MASTER_TEMPLATE_URL

echo 'Template valid, creating master stack'
aws cloudformation create-stack \
	--stack-name $MASTER_STACK_NAME \
	--template-body $MASTER_TEMPLATE_URL \
	--capabilities CAPABILITY_NAMED_IAM \
	--parameters ParameterKey=ClusterName,ParameterValue=$CLUSTER_NAME

echo 'Waiting until master stack create completes'
aws cloudformation wait stack-create-complete --stack-name $MASTER_STACK_NAME

echo '$MASTER_STACK_NAME created successfully'

# nodes
NODES_STACK_NAME="$CLUSTER_NAME-k8s-nodes"
NODES_TEMPLATE_URL="file://nodes.yml"

echo "Checking nodes template validity"
aws cloudformation validate-template --template-body $NODES_TEMPLATE_URL

echo "Template valid, creating nodes stack"

aws cloudformation create-stack \
	--stack-name $NODES_STACK_NAME \
	--template-body $NODES_TEMPLATE_URL \
	--capabilities CAPABILITY_NAMED_IAM \
	--parameters ParameterKey=ClusterName,ParameterValue=$CLUSTER_NAME

echo "Waiting until nodes stack create completes"
aws cloudformation wait stack-create-complete --stack-name $NODES_STACK_NAME

echo "$NODES_STACK_NAME created successfully"

EKS_ENDPOINT=$(aws eks describe-cluster --name $CLUSTER_NAME --query cluster.endpoint)
EKS_CERTIFICATE_AUTH=$(aws eks describe-cluster --name $CLUSTER_NAME --query cluster.certificateAuthority.data)

mkdir -p $HOME/.kube

sed "s/EKS_CLUSTER/$CLUSTER_NAME/g" config/kube_config.dist.yml > config_tmp.yml
sed "s,EKS_ENDPOINT,$EKS_ENDPOINT,g" config_tmp.yml > config_tmp2.yml
sed "s/EKS_CERTIFICATION_AUTHORITY/$EKS_CERTIFICATE_AUTH/g" config_tmp2.yml > config_tmp3.yml

cp config_tmp3.yml $HOME/.kube/config_$CLUSTER_NAME

rm config_tmp.yml
rm config_tmp2.yml
rm config_tmp3.yml

mkdir -p $HOME/.kube

echo "Running: export KUBECONFIG=$HOME/.kube/config_$CLUSTER_NAME"
export KUBECONFIG=$HOME/.kube/config_$CLUSTER_NAME

kubectl get nodes

## get IAM profile for nodes

ARN_INSTANCE_PROFILE_ROLE=$(aws cloudformation describe-stacks --stack-name $NODES_STACK_NAME --query 'Stacks[0].Outputs[0].OutputValue')

sed "s,ARN_INSTANCE_PROFILE_ROLE,$ARN_INSTANCE_PROFILE_ROLE,g" config/nodes_auth.dist.yml > config/nodes_auth.yml

kubectl apply -f config/nodes_auth.yml

kubectl get nodes

rm config/nodes_auth.yml

echo "Run: kubectl get nodes --watch"
