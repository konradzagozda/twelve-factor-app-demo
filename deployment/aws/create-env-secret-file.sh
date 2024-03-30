#!/bin/bash
# usage: ./3.create-secret-file.sh

PROFILE=$(terraform -chdir=2.main.tf output -raw profile)
# Output .env file
ENV_FILE="cloud.secret.env"

# Parameters to fetch from SSM
SECRETS=(
    "/todo_api/DB_PASSWORD"
    "/todo_api/SECRET_KEY"
)

# Clear the file content before starting
: > "$ENV_FILE"

# Fetch each parameter from SSM and append it to the .env file
for SECRET in "${SECRETS[@]}"; do
    # Extract the parameter name for the .env file
    ENV_NAME=$(echo "$SECRET" | awk -F'/' '{print $NF}')

    # Fetch the parameter value from AWS SSM using the specified profile
    VALUE=$(AWS_PROFILE=$PROFILE aws secretsmanager get-secret-value --secret-id $SECRET --query 'SecretString' --output text)

    # Append to the .env file
    echo "${ENV_NAME}=${VALUE}" >> "$ENV_FILE"
done

echo "Environment file $ENV_FILE created."