#!/bin/bash
# usage: ./4.deploy.sh TAG
set -ex

TAG=$1

SHARED_ACCOUNT_ID=$(terraform -chdir=1.shared-services.tf output -raw account_id)
REGION=$(terraform -chdir=2.main.tf output -raw region)
export AWS_PROFILE=$(terraform -chdir=2.main.tf output -raw profile)
export AWS_PAGER=""

ECR_BASE_URL="${SHARED_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"
API_IMAGE="${ECR_BASE_URL}/todo-api:${TAG}"
JOB_IMAGE="${ECR_BASE_URL}/todo-api-job:${TAG}"

RELEASES_BUCKET=$(terraform -chdir=2.main.tf output -raw releases_bucket_name)
aws s3 cp "s3://${RELEASES_BUCKET}/todo-api/${TAG}/release-info.json" release-info.json

ENV_FILE_URL=$(jq -r '.envFile' release-info.json)
SECRET_ENV_FILE_URL=$(jq -r '.secretEnvFile' release-info.json)

aws s3 cp "${ENV_FILE_URL}" cloud.env
aws s3 cp "${SECRET_ENV_FILE_URL}" cloud.secret.env

aws eks --region ${REGION} update-kubeconfig --name $(terraform -chdir=2.main.tf output -raw cluster_name)

kubectl apply -f k8s/namespace.yaml
kubectl config set-context --current --namespace=todo-api

kubectl delete configmap todo-api-config --ignore-not-found=true
kubectl create configmap todo-api-config --from-env-file=cloud.env

kubectl delete secret todo-api-secret --ignore-not-found=true
kubectl create secret generic todo-api-secret --from-env-file=cloud.secret.env

helm upgrade --install todo-api ./chart \
    --set images.api="${API_IMAGE}" \
    --set images.job="${JOB_IMAGE}"

