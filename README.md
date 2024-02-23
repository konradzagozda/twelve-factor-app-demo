# 12factor app demo

## Description

Sample modern application created to demonstrate full adherence to `The Twelve-Factor App` methodology.

## XII-Factor Application

- **declarative format for setup automation** - achieved with `ansible`
- **clean contract with underlying system** - only `unix-like` system is needed, for windows use WSL2.
- **suitable for deployment on modern cloud platforms** - achieved with `kubernetes`
- TODO: no dev/prod deployment yet **Minimize divergence** between development and production - local / dev / prod environments differs mostly just by configuration settings
- TODO: can **scale up** - achieved with `kubernetes` and autoscalling cloud capabilities.

### I. Codebase - One codebase tracked in revision control, many deploys

- tracked in a version control system - achieved with `git`
- one-to-one correlation between the codebase and the app
- one codebase per app, many deploys of the app
- production site, one staging site, copy of the app running in local development environment

### II. Dependencies

- TODO: no reliance on implicit existence of system-wide packages - achieved with `venv`
- exact dependency declaration - achieved with `poetry.lock`
- no reliance on the implicit existence of any system tools (at runtime)

### III. Config

- TODO: (cloud) strict separation of config from code - achieved with `environment variables`
- codebase could be made open source at any moment, without compromising any credentials
- TODO: no grouping (local/dev/prod), env vars, fully orthogonal to other env vars independently managed for each deploy

### IV. Backing services

- no distinction between local and third party services
- attached resources (DB), accessed via a URL or other locator/credentials are stored in the config

### V. Build, release, run

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
