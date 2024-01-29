# simple-app

## Description

Sample modern application created to demonstrate full adherence to `The Twelve-Factor App` methodology.

## Dependencies

Install following dependencies:

- minikube
- docker
- python3.11
- poetry
- vscode (recommended)

## Setting Up The Project

Set up backend for your IDE:

1. `cd backend && poetry install && poetry self add poetry-plugin-export && poetry shell`
2. move to root dir and activate pre-commit: `pre-commit install`

Run the App:

1. `./setup.sh` - it will boot minikube cluster and deploy all the components with reload on change

If you close the terminal after running `./setup.sh` you can expose service once again using `minikube service backend-service --url -n simple-app` command

Use `./execute.sh` to execute commands within the container e.g. `./execute.sh python manage.py migrate`

## Tech Stack

- backend: django, django-ninja, pytest, uvicorn
- kubernetes for local deployment

## Features

- Dockerfiles built with best practice in mind: minimal size, security, single Dockerfile for every environment
- Distinction between config(configMap) and sensitive config(secrets)
