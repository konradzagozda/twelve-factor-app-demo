#!/bin/bash
# usage: ./install-LBC.sh
set -x


export AWS_PROFILE=$(terraform -chdir=2.cluster.tf output -raw profile)
CLUSTER_NAME=$(terraform -chdir=2.cluster.tf output -raw cluster_name)

# create OIDC provider
OICD_ID=$(aws eks describe-cluster --name $CLUSTER_NAME --query "cluster.identity.oidc.issuer" --output text | cut -d '/' -f 5)
eksctl utils associate-iam-oidc-provider --cluster $CLUSTER_NAME --approve # looks redundant

aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json
# can be tf

ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)

eksctl create iamserviceaccount \
  --cluster=$CLUSTER_NAME \
  --namespace=kube-system \
  --name=aws-load-balancer-controller-4 \
  --role-name AmazonEKSLoadBalancerControllerRole4 \
  --attach-policy-arn=arn:aws:iam::$ACCOUNT_ID:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve

helm repo add eks https://aws.github.io/eks-charts
helm repo update eks

VPC_ID=$(terraform -chdir=2.cluster.tf output -raw vpc_id)

aws eks \
    --region $(cd 2.cluster.tf && terraform output -raw region) update-kubeconfig \
    --name $(cd 2.cluster.tf && terraform output -raw cluster_name)

kubectl rollout -n kube-system restart deployment coredns 

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=$CLUSTER_NAME \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller-4 \
  --set vpcId=$VPC_ID