#!/bin/bash
# usage: ./build.sh SEMVER
set -xe

SEMVER=$1
DATETIME=$(date "+%Y_%m_%d_%H_%M_%S")
TAG="${SEMVER}-${DATETIME}"

SHARED_ACCOUNT_ID=$(terraform -chdir=1.shared-services.tf output -raw account_id)
REGION=$(terraform -chdir=2.main.tf output -raw region)
export AWS_PROFILE=$(terraform -chdir=2.main.tf output -raw profile)
export AWS_PAGER=""

aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${SHARED_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com

cd ../..

BRANCH=$(git rev-parse --abbrev-ref HEAD)
COMMIT=$(git rev-parse HEAD)

docker build --platform linux/amd64 \
    --build-arg BRANCH="${BRANCH}" \
    --build-arg COMMIT="${COMMIT}" \
    --build-arg TAG="${TAG}" \
    -t todo-api todo-api/src

docker build --platform linux/amd64 -t todo-api-job todo-api/tests

API_IMAGE=${SHARED_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/todo-api:${TAG}
JOB_IMAGE=${SHARED_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/todo-api-job:${TAG}

docker tag todo-api ${API_IMAGE}
docker tag todo-api-job ${JOB_IMAGE}

docker push ${API_IMAGE}
docker push ${JOB_IMAGE}

echo ${TAG} > deployment/aws/.todo_api_last_build_tag