#!/bin/bash
# usage: ./1.post-apply.sh
set -x


export AWS_PROFILE=$(terraform -chdir=2.main.tf output -raw profile)
CLUSTER_NAME=$(terraform -chdir=2.main.tf output -raw cluster_name)
ACCOUNT_ID=$(terraform -chdir=2.main.tf output -raw account_id)
VPC_ID=$(terraform -chdir=2.main.tf output -raw vpc_id)

aws eks \
    --region $(cd 2.main.tf && terraform output -raw region) update-kubeconfig \
    --name $(cd 2.main.tf && terraform output -raw cluster_name)


kubectl apply -f k8s/aws-observability-namespace.yaml
kubectl apply -f k8s/aws-logging-cloudwatch-configmap.yaml

kubectl create sa aws-load-balancer-controller -n kube-system
kubectl annotate sa aws-load-balancer-controller -n kube-system "eks.amazonaws.com/role-arn=arn:aws:iam::${ACCOUNT_ID}:role/AmazonEKSLoadBalancerControllerRole"

kubectl rollout -n kube-system restart deployment coredns 

helm repo add eks https://aws.github.io/eks-charts
helm repo update eks

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=${CLUSTER_NAME} \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set vpcId=${VPC_ID}
