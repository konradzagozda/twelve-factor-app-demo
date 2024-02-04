# simple-app

## Description

Sample modern application created to demonstrate full adherence to `The Twelve-Factor App` methodology.

## Setting Up The Project

1. Install following dependencies:

   - minikube
   - docker
   - python3.11
   - poetry
   - pyenv
   - git
   - ansible
   - vscode (recommended)

2. Run automation playbook that will scaffold project for you:

   `ansible-playbook setup.yaml`

3. Activate virtualenv

   - in your IDE
   - in your shell: `cd backend && poetry shell`

4. Access backend service using `minikube service backend-service --url -n simple-app`

## Tests

Run the tests using `./execute-in-test.container.sh pytest`
In parallel: `./execute-in-test.container.sh pytest -n 4`

## Tech Stack

- backend:
  - django, django-ninja,
  - pytest, pytest-django,
  - uvicorn
- kubernetes
- ansible

## Features

- Dockerfiles built with best practice in mind: minimal size, security, single Dockerfile for every environment
- Distinction between config(configMap) and sensitive config(secrets)

## XII-Factor Application

- declarative format for setup automation achieved with `ansible`.
