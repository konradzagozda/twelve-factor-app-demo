# 12factor app demo

## Description

Sample modern application created to demonstrate full adherence to `The Twelve-Factor App` methodology.

## XII-Factor Application

- **declarative format for setup automation** - achieved with `ansible`
- **clean contract with underlying system** - only `unix-like` system is needed, for windows use WSL2.
- **suitable for deployment on modern cloud platforms** - achieved with `kubernetes`
- TODO: no dev/prod deployment yet **Minimize divergence** between development and production - local / dev / prod environments differs mostly just by configuration settings
- TODO: can **scale up** - achieved with `kubernetes` and autoscalling cloud capabilities.

### Codebase - One codebase tracked in revision control, many deploys

## Setting Up The Project

1. Install following dependencies:

   - kind
   - docker
   - poetry
   - pyenv
   - python3.11 (pyenv install 3.11.8; pyenv global 3.11.8)
   - git
   - ansible
   - vscode (recommended)

2. Run automation playbook that will scaffold project for you:

   `ansible-playbook setup.yaml`

3. Activate virtualenv

   - in your IDE
   - in your shell: `cd backend && poetry shell`

4. Access backend service: `http://localhost:30000`

## Tests

Run the tests using `./execute-in-test-container.sh pytest`
In parallel: `./execute-in-test-container.sh pytest -n 4`

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

## Setup automation tests

This commands will run setup automation inside ubuntu container

```sh
docker build -f tests/project-setup/ubuntu/Dockerfile -t ubuntu-test .
docker run -it --mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock \
   --mount type=bind,source="$(pwd)",target="$(pwd)" \
   --network host \
   ubuntu-test \
   bash -c "cd /$(pwd)/tests/project-setup/ubuntu && ./test.sh"
```
