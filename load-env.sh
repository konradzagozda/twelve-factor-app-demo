#!/bin/bash
# script for loading environments from file
# usage: `source load-env.sh`

# Export the variables
for env_file in local.env local.secret.env; do
    if [ ! -f "$env_file" ]; then
        echo "Warning: File $env_file does not exist."
        continue
    fi

    while read -r line; do
        # Skip empty lines and lines starting with #
        if [[ -z "$line" || "$line" =~ ^# ]]; then
            continue
        fi

        # Use export to set the variables
        export "$line"
    done < "$env_file"
done

echo "Environment variables loaded successfully"