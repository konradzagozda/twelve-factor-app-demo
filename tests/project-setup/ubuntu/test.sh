#!/bin/bash

cd ../../../backend
PYTHON_INTERPRETER=$(poetry run which python)
cd ..
# setup
ansible-playbook setup.yaml -e "ansible_python_interpreter=${PYTHON_INTERPRETER}"

# test if service is available
response=$(curl -I -L http://localhost:30000/api/docs 2>/dev/null | grep HTTP/ | tail -n 1)

if echo "$response" | grep -q "200 OK"; then
  echo "Result: OK"
  exit 0
else
  echo "Result: Not OK. Response was: $response"
  exit 1
fi