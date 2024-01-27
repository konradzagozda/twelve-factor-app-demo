#!/bin/bash
set -x

# prepare local cluster
minikube delete
minikube start

# prepare backend for build
cd backend
poetry export -f requirements.txt --output requirements.txt

