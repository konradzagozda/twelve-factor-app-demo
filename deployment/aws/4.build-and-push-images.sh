#!/bin/bash
# usage: ./build-and-push-images.sh TAG
set -x

TAG=$1

ACCOUNT_ID=$(terraform -chdir=2.cluster.tf output -raw account_id)
REGION=$(terraform -chdir=2.cluster.tf output -raw region)
PROFILE=$(terraform -chdir=2.cluster.tf output -raw profile)

aws --profile $PROFILE ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

# Build the Docker images
cd ../..
docker build -t todo-api-web:$TAG todo-api/src
docker build -t todo-api-job:$TAG todo-api/tests

# Tag the Docker images
docker tag todo-api-web:$TAG $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/todo-api-web:$TAG
docker tag todo-api-job:$TAG $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/todo-api-job:$TAG

# Push the Docker images
docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/todo-api-web:$TAG
docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/todo-api-job:$TAG