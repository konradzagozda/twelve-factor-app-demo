#!/bin/bash
# usage: ./deploy.sh SEMVER
set -x

SEMVER=$1
DATETIME=$(date "+%Y_%m_%d_%H_%M_%S")
TAG="${SEMVER}-${DATETIME}"

ACCOUNT_ID=$(terraform -chdir=tf output -raw account_id)
REGION=$(terraform -chdir=tf output -raw region)
BRANCH=$(git rev-parse --abbrev-ref HEAD)
export AWS_PROFILE=$(terraform -chdir=tf output -raw profile)
export AWS_PAGER=""

aws ssm put-parameter --name "/todo_api/TAG" --value "${TAG}" --type "String" --overwrite --region ${REGION}
aws ssm put-parameter --name "/todo_api/BRANCH" --value "$(git rev-parse --abbrev-ref HEAD)" --type "String" --overwrite --region ${REGION}

aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com

# Build the Docker images
cd ../..
docker build --platform linux/amd64 -t todo-api todo-api/src
docker build --platform linux/amd64 -t todo-api-job todo-api/tests

# Tag the Docker images
export API_IMAGE=${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/todo-api:${TAG}
export JOB_IMAGE=${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/todo-api-job:${TAG}

docker tag todo-api ${API_IMAGE}
docker tag todo-api-job ${JOB_IMAGE}

# Push the Docker images
docker push ${API_IMAGE}
docker push ${JOB_IMAGE}

cd deployment/aws

aws eks \
    --region ${REGION} update-kubeconfig \
    --name $(cd tf && terraform output -raw cluster_name)

kubectl apply -f k8s/namespace.yaml
kubectl config set-context --current --namespace=todo-api

./create-env-file.sh
./create-env-secret-file.sh

kubectl delete configmap todo-api-config --ignore-not-found=true
kubectl create configmap todo-api-config --from-env-file=cloud.env

kubectl delete secret todo-api-secret --ignore-not-found=true
kubectl create secret generic todo-api-secret --from-env-file=cloud.secret.env

helm upgrade --install todo-api ./chart --set images.api=${API_IMAGE} --set images.job=${JOB_IMAGE}

