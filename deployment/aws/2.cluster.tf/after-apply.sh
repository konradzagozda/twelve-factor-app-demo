#!/bin/bash
# usage: ./after-apply.sh PROFILE REGION
set -x


AWS_PROFILE=$1
AWS_REGION=$2
DB_HOST=$(terraform output -raw db_host)

export AWS_PAGER=""
aws --region $AWS_REGION --profile $AWS_PROFILE ssm put-parameter --name "/todo_api/DB_HOST" --type "String" --value "$DB_HOST" --overwrite 