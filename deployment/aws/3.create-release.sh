#!/bin/bash
# usage: ./create-release.sh
set -xe

export AWS_PROFILE=$(terraform -chdir=2.main.tf output -raw profile)
export AWS_PAGER=""
REGION=$(terraform -chdir=2.main.tf output -raw region)

./create-env-file.sh
./create-env-secret-file.sh

ENV_FILE="./cloud.env"
SECRET_ENV_FILE="./cloud.secret.env"
CONFIGURATIONS_BUCKET=$(terraform -chdir=2.main.tf output -raw configurations_bucket_name)
TAG=$(cat .todo_api_last_build_tag)

ENV_FILE_URL="s3://${CONFIGURATIONS_BUCKET}/todo-api/${TAG}/.env"
SECRET_ENV_FILE_URL="s3://${CONFIGURATIONS_BUCKET}/todo-api/${TAG}/.secret.env"

aws s3 cp "${ENV_FILE}" "${ENV_FILE_URL}" --region ${REGION}
aws s3 cp "${SECRET_ENV_FILE}" "${SECRET_ENV_FILE_URL}" --region ${REGION}

RELEASE_FILE="./release-info.json"
echo "{\"envFile\":\"${ENV_FILE_URL}\",\"secretEnvFile\":\"${SECRET_ENV_FILE_URL}\"}" > ${RELEASE_FILE}

RELEASES_BUCKET=$(terraform -chdir=2.main.tf output -raw releases_bucket_name)
RELEASE_FILE_URL="s3://${RELEASES_BUCKET}/todo-api/${TAG}/release-info.json"
aws s3 cp "${RELEASE_FILE}" "${RELEASE_FILE_URL}" --region ${REGION}