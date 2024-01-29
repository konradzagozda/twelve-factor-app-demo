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


# create namespace
cd deployment/local
kubectl apply -f namespace.yaml
kubectl config set-context --current --namespace=simple-app

# create configs 
kubectl create configmap backend-config --from-env-file=../../local.env
kubectl create secret generic backend-secret --from-env-file=../../local.secret.env
sleep 5

# create database
kubectl apply -f database-volume-claim.yaml
kubectl apply -f database-deployment.yaml
kubectl apply -f database-service.yaml
sleep 10

# create backend
kubectl apply -f backend-deployment.yaml
kubectl apply -f backend-service.yaml
sleep 10

# run migrations
../../execute.sh python manage.py migrate

# expose services
echo "Use following IP to acces the app."
minikube service backend-service --url -n simple-app