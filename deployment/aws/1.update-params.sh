#!/bin/bash
# usage: ./1.update-params.sh
set -x

REGION=$(terraform -chdir=2.cluster.tf output -raw region)
PROFILE=$(terraform -chdir=2.cluster.tf output -raw profile)
DB_HOST=$(terraform -chdir=2.cluster.tf output -raw db_host)

export AWS_PAGER=""
aws --region $REGION --profile $PROFILE ssm put-parameter --name "/todo_api/DB_HOST" --type "String" --value "$DB_HOST" --overwrite 