# XII Factor Application Demo

## Description

Example application created to demonstrate full adherence to `The Twelve-Factor App` methodology.

## XII-Factor Application

- **declarative format for setup automation** - achieved with `ansible`
- **clean contract with underlying system** - only `unix-like` system is needed, for windows use WSL2.
- **suitable for deployment on modern cloud platforms** - achieved with `kubernetes`
- **Minimize divergence** between development and production - local / dev / prod environments differs mostly just by configuration settings. Local deployment achieved using `kind`, cloud deployments achieved with `aws eks`.
- can **scale up** - achieved with `aws fargate` (TODO: horizontal pod autoscaler), `aws aurora serverless`

### I. Codebase - One codebase tracked in revision control, many deploys

- tracked in a version control system - achieved with `git`
- one-to-one correlation between the codebase and the app
- one codebase per app, many deploys of the app
- production site, one staging site, copy of the app running in local development environment - achieved with `kind`

### II. Dependencies - Explicitly declare and isolate dependencies

- no reliance on implicit existence of system-wide packages - achieved with `venv`
- exact dependency declaration - achieved with `poetry.lock`
- no reliance on the implicit existence of any system tools (at runtime) - achieved with `venv`

### III. Config - Store config in the environment

- strict separation of config from code - achieved with `environment variables`, `aws parameter store`, `aws secret manager`
- codebase could be made open source at any moment, without compromising any credentials
- no grouping (local/dev/prod), env vars, fully orthogonal to other env vars independently managed for each deploy

### IV. Backing services - Treat backing services as attached resources

- no distinction between local and third party services
- attached resources (DB), accessed via a URL or other locator/credentials are stored in the config

### V. Build, release, run - Strictly separate build and run stages

Deploy has 3 stages:

1. build - create executable bundle from binaries and assets
2. release - combines build with config, ready for immediate execution
3. run(runtime) - runs the app in execution environment

- Every release have unique release ID in format: `major.minor.patch-datetime`
- Release cannot be mutated once created.
- Builds are initiated on push to main branch. (TODO: CI/CD system)

### VI. Processes - Execute the app as one or more stateless processes

- Processes are stateless and share-nothing. Any data that needs to persist must be stored in a stateful backing service.
- **No** reliance upon **sticky-sessions**.

### VII. Port binding - Export services via port binding

- The twelve-factor app is completely self-contained - achieved with `uvicorn` in dependency declaration
- exports HTTP as a service by binding to a port

### VIII. Concurrency - Scale out via the process model

- processes are a first class citizen
- multiple processes running on multiple physical machines
- process model truly shines when it comes time to **scale out**
- never daemonize or write PID files

### IX. Disposability - Maximize robustness with fast startup and graceful shutdown

- processes are disposable, meaning they can be started or stopped at a moment’s notice
- minimize startup time - achieved with `containerization with k8s and docker`
- shut down gracefully on `SIGTERM` - refuse any new requests, allow any current requests to finish, then exit
- robust against sudden death, handle unexpected, non-graceful terminations

### X. Dev/prod parity - Keep development, staging, and production as similar as possible

- designed for continuous deployment by keeping the gap between development and production small
- write code and have it deployed hours or even just minutes later
- developers who wrote code are closely involved in deploying it and watching its behavior in production
- resists the urge to use different backing services between development and production

### XI. Logs - Treat logs as event streams

- app never concerns itself with routing or storage of its output stream
- writes its event stream, unbuffered, to `stdout`
- each process’ stream is captured in execution environment, collated together with all other streams from the app, and routed to final destinations for viewing and long-term archival - logs are routed via `fluentbit` to `cloudwatch`

### XII. Admin processes - Run admin/management tasks as one-off processes

- run in an identical environment as the regular long-running processes of the app
- run against a release
- favors languages which provide a REPL shell out of the box

achieved with `kubernetes job` and `django manage.py <command>`

## Setting Up The Project

1. Install following dependencies:

   - kind
   - docker
   - poetry 1.8.2+
   - pyenv
   - python3.12 (pyenv install 3.12; pyenv global 3.12)
   - git
   - ansible
   - yq
   - kubectl
   - helm
   - vscode (recommended)

2. Run automation playbook that will scaffold project for you:

   `ansible-playbook setup.ansible.yaml`

3. Activate virtualenv

   - in your IDE
   - in your shell: `cd todo-api && poetry shell`

4. Access todo-api service: `http://localhost:30000/api/docs`

## Admin processes

- `./execute.sh -m pytest`
- `./execute.sh -m pytest -n 4`
- `./execute.sh src/manage.py migrate`
- `./execute.sh src/manage.py makemigrations`

## Tech Stack

### Application

- django, django-ninja
- pytest, pytest-django
- uvicorn

### Infrastructure

- kubernetes
- ansible
- terraform

## Setup automation tests

This commands will run setup automation inside ubuntu container

```sh
docker build -f tests/project-setup/ubuntu/Dockerfile -t ubuntu-test .
docker run -it --mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock \
   --mount type=bind,source="$(pwd)",target="$(pwd)" \
   --network host \
   ubuntu-test sh -c "cd $(pwd) && ansible-playbook setup.ansible.yaml"
```

## Cloud Infrastructure

### Requirements

- AWS account for each environment (dev / prod) and for common resources with configured profiles in your `~/.aws/config` and `~/.aws/credentials`

`cd deployment/aws`

### Day 1

#### Common Infrastructure

1. `cd 1.shares-services.tf`
2. create var file called `default.auto.tfvars`, fill it with variables (`variables.tf`)
3. `terraform init && terraform apply`

#### Workload Infrastructure

1. `cd 2.main.tf`
2. create two var files called `dev.tfvars` and `prod.tfvars`, fill it with variables (`variables.tf`)
3. `terraform init`

Repeat these commands for `dev` and `prod`:

1. `terraform workspace new <dev/prod> && terraform apply -var-file <dev/prod>.tfvars`
2. `cd .. && ./1.post-apply.sh`

### Day N | Deployment

Deployment is split into 3 processes: `build`, `create release`, `deploy`

#### Build

Use `dev` environment for building:

1. `terraform -chdir=2.main.tf workspace select dev`
2. `./2.build.sh 0.0.1`

#### Release

Release is a pair of (`TAG`, `CONFIG`).  
TAG is used to select docker images uploaded in build step to ECR.  
CONFIG is set of environment files created in this stage and uploaded to CONFIG bucket.  
Releases info is stored in a seperate bucket in a way, that when you have a `TAG` you can deploy it immediately.  
**Release is environment specific, you must create release per environment** since configurations are often environmental.

1. `./create-release.sh` - it will fetch latest build, create and upload a release

#### Deployment

Fetches necessary info from release bucket and deploys application to the cluster.

1. `./4.deploy.sh 0.0.1-2024_03_30_10_10_21`
