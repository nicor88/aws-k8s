#!/usr/bin/env bash

CLUSTER_NAME="ef-data"
EKS_ENDPOINT=$(aws eks describe-cluster --name $CLUSTER_NAME --query cluster.endpoint)
EKS_CERTIFICATE_AUTH=$(aws eks describe-cluster --name $CLUSTER_NAME --query cluster.certificateAuthority.data)

#EKS_ENDPOINT_CLEAN=$(echo $EKS_ENDPOINT | sed 's/"//g')
#echo $EKS_ENDPOINT_CLEAN

mkdir -p $HOME/.kube

sed "s/EKS_CLUSTER/$CLUSTER_NAME/g" config/kube_config.dist.yml > config_tmp.yml
sed "s,EKS_ENDPOINT,$EKS_ENDPOINT,g" config_tmp.yml > config_tmp2.yml
sed "s/EKS_CERTIFICATION_AUTHORITY/$EKS_CERTIFICATE_AUTH/g" config_tmp2.yml > config_tmp3.yml


cp config_tmp3.yml $HOME/.kube/config_$CLUSTER_NAME

rm config_tmp.yml
rm config_tmp2.yml
rm config_tmp3.yml

echo "Run: export KUBECONFIG=$HOME/.kube/config_$CLUSTER_NAME"
