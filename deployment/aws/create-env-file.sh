#!/bin/bash
# usage: ./2.create-env-file.sh

PROFILE=$(terraform -chdir=2.main.tf output -raw profile)
# Output .env file
ENV_FILE="cloud.env"

# Parameters to fetch from SSM
PARAMS=(
    "/todo_api/ALLOWED_HOSTS"
    "/todo_api/DEBUG"
    "/todo_api/DB_NAME"
    "/todo_api/DB_USER"
    "/todo_api/DB_HOST"
    "/todo_api/DB_PORT"
)

# Clear the file content before starting
: > "$ENV_FILE"

# Fetch each parameter from SSM and append it to the .env file
for PARAM in "${PARAMS[@]}"; do
    # Extract the parameter name for the .env file
    ENV_NAME=$(echo "$PARAM" | awk -F'/' '{print $NF}')

    # Fetch the parameter value from AWS SSM using the specified profile
    VALUE=$(AWS_PROFILE=$PROFILE aws ssm get-parameter --name "$PARAM" --query 'Parameter.Value' --output text)

    # Append to the .env file
    echo "${ENV_NAME}=${VALUE}" >> "$ENV_FILE"
done

echo "Environment file $ENV_FILE created."