#!/bin/sh
set -e

CLUSTER_NAME="dev-data"
STACK_NAME="$CLUSTER_NAME-k8s-nodes"
TEMPLATE_URL="file://nodes.yml"

if [ -z "$AWS_DEFAULT_PROFILE" ]; then
    echo "Please set the AWS_DEFAULT_PROFILE environment variable"
    exit 1
fi

echo 'Checking template validity'
aws cloudformation validate-template --template-body $TEMPLATE_URL

echo 'Template valid, creating stack'
aws cloudformation create-stack \
	--stack-name $STACK_NAME \
	--template-body $TEMPLATE_URL \
	--capabilities CAPABILITY_NAMED_IAM \
	--parameters ParameterKey=ClusterName,ParameterValue=$CLUSTER_NAME

echo 'Waiting until stack create completes'
aws cloudformation wait stack-create-complete --stack-name $STACK_NAME

echo 'Stack created successfully'
