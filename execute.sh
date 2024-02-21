#!/bin/bash
# execute commands inside a container

kubectl config set-context --current --namespace=12factor
POD_NAME=$(kubectl get pods -l app=backend -o jsonpath="{.items[0].metadata.name}")
kubectl exec $POD_NAME -- "$@"