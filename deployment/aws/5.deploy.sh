#!/bin/bash
# usage: ./deploy.sh TAG
set -x

TAG=$1

ACCOUNT_ID=$(terraform -chdir=2.cluster.tf output -raw account_id)
REGION=$(terraform -chdir=2.cluster.tf output -raw region)
PROFILE=$(terraform -chdir=2.cluster.tf output -raw profile)

aws --profile $PROFILE ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

# Build the Docker images
cd ../..
docker build --platform linux/amd64 -t todo-api todo-api/src
docker build --platform linux/amd64 -t todo-api-job todo-api/tests

# Tag the Docker images
export WEB_IMAGE=$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/todo-api:$TAG
export JOB_IMAGE=$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/todo-api-job:$TAG

docker tag todo-api $WEB_IMAGE
docker tag todo-api-job $JOB_IMAGE

# Push the Docker images
docker push $WEB_IMAGE
docker push $JOB_IMAGE

cd deployment/aws

aws eks \
    --profile $PROFILE \
    --region $REGION update-kubeconfig \
    --name $(cd 2.cluster.tf && terraform output -raw cluster_name)

kubectl apply -f k8s/12factor-namespace.yaml
kubectl config set-context --current --namespace=12factor

kubectl delete configmap todo-api-config --ignore-not-found=true
kubectl create configmap todo-api-config --from-env-file=cloud.env

kubectl delete secret todo-api-secret --ignore-not-found=true
kubectl create secret generic todo-api-secret --from-env-file=cloud.secret.env

envsubst < k8s/todo-api-deployment.yaml.template | kubectl apply -f -

export JOB_ARGS="src/manage.py migrate"

kubectl delete job todo-api-job --ignore-not-found=true
envsubst < k8s/todo-api-job.yaml.template | kubectl apply -f -

kubectl apply -f k8s/todo-api-service.yaml
kubectl apply -f k8s/todo-api-ingress.yaml


