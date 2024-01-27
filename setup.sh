#!/bin/bash
set -x

# prepare local cluster
minikube delete
minikube start
nohup minikube mount .:/mnt/project &
sleep 30 # wait until cluster and mount is ready

# prepare backend for build
cd backend && poetry export -f requirements.txt --output requirements.txt && cd ..

# build images in minikube
minikube ssh << EOF
cd /mnt/project/backend
docker build -t backend .
exit
EOF


# create kubernetes resources
cd k8s/local
kubectl apply -f namespace.yaml
kubectl config set-context --current --namespace=simple-app

# create configs 
kubectl create configmap backend-config --from-env-file=../../local.env
sleep 5

kubectl apply -f backend-deployment.yaml
kubectl apply -f backend-service.yaml
sleep 10

# expose services
echo "Use following IPs to acces the app."
minikube service --all --url -n simple-app