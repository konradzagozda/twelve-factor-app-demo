#!/bin/bash
# example usage: ./execute.sh manage.py migrate

# Command line arguments
ARGS="$*"

# Define a static job name
JOB_NAME="todo-api-job"

kubectl delete job $JOB_NAME --ignore-not-found

# Replace the placeholder for ARGS in the template and apply it
sed "s|ARGS_PLACEHOLDER|$ARGS|g" deployment/local/todo-api-job-template.yaml | kubectl apply -f -

# Wait for the job's pod to appear
echo "Waiting for the job's pod to be created..."
until POD_NAME=$(kubectl get pods --selector=job-name=$JOB_NAME --output=jsonpath='{.items[0].metadata.name}'); do
    echo -n "."
    sleep 1
done
echo "Pod has been created. Pod name: $POD_NAME"

sleep 3
kubectl logs -f $POD_NAME