#!/bin/bash
# usage: ./install-LBC.sh
set -x


export AWS_PROFILE=$(terraform -chdir=2.cluster.tf output -raw profile)
CLUSTER_NAME=$(terraform -chdir=2.cluster.tf output -raw cluster_name)

# create OIDC provider
OICD_ID=$(aws eks describe-cluster --name $CLUSTER_NAME --query "cluster.identity.oidc.issuer" --output text | cut -d '/' -f 5)
eksctl utils associate-iam-oidc-provider --cluster $CLUSTER_NAME --approve

aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json

ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)

eksctl create iamserviceaccount \
  --cluster=my-cluster \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn=arn:aws:iam::$ACCOUNT_ID:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve

helm repo add eks https://aws.github.io/eks-charts
helm repo update eks

VPC_ID=$(terraform -chdir=2.cluster.tf output -raw vpc_id)

aws eks \
    --region $(cd 2.cluster.tf && terraform output -raw region) update-kubeconfig \
    --name $(cd 2.cluster.tf && terraform output -raw cluster_name)

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=my-cluster \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set vpcId=$VPC_ID