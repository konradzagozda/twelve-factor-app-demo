#!/bin/bash
# script for loading environments from file
# usage: `source load-env.sh`

# Export the variables
while read -r line; do
    # Skip empty lines and lines starting with #
    if [[ -z "$line" || "$line" =~ ^# ]]; then
        continue
    fi

    # Use export to set the variables
    export "$line"
done < "local.env"

echo "Environment variables loaded successfully"