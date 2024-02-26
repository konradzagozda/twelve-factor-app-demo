# 12factor app demo

## Description

Example application created to demonstrate full adherence to `The Twelve-Factor App` methodology.

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

### II. Dependencies - Explicitly declare and isolate dependencies

- TODO: no reliance on implicit existence of system-wide packages - achieved with `venv`
- exact dependency declaration - achieved with `poetry.lock`
- no reliance on the implicit existence of any system tools (at runtime) - achieved with `venv`

### III. Config - Store config in the environment

- TODO: (cloud) strict separation of config from code - achieved with `environment variables`
- codebase could be made open source at any moment, without compromising any credentials
- TODO: no grouping (local/dev/prod), env vars, fully orthogonal to other env vars independently managed for each deploy

### IV. Backing services - Treat backing services as attached resources

- no distinction between local and third party services
- attached resources (DB), accessed via a URL or other locator/credentials are stored in the config

### TODO: V. Build, release, run - Strictly separate build and run stages

Deploy has 3 stages:

1. build - create executable bundle from binaries and assets
2. release - combines build with config, ready for immediate execution
3. run(runtime) - runs the app in execution environment

- Every release have unique release ID in format: `2011-04-06-20:32:17`
- Release cannot be mutated once created.
- Builds are initiated on push to main branch.

### VI. Processes - Execute the app as one or more stateless processes

- Processes are stateless and share-nothing. Any data that needs to persist must be stored in a stateful backing service.
- **No** reliance upon **sticky-sessions**.

### VII. Port binding - Export services via port binding

- The twelve-factor app is completely self-contained - achieved with `uvicorn` in dependency declaration
- exports HTTP as a service by binding to a port - access it on `url:30000`

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
- TODO: each process’ stream is captured in execution environment, collated together with all other streams from the app, and routed to final destinations for viewing and long-term archival

### XII. Admin processes - Run admin/management tasks as one-off processes

- run in an identical environment as the regular long-running processes of the app
- run against a release
- favors languages which provide a REPL shell out of the box

achieved with `kubernetes job` and `django manage.py <command>`

## Setting Up The Project

1. Install following dependencies:

   - kind
   - docker
   - poetry
   - pyenv
   - python3.11 (pyenv install 3.11.8; pyenv global 3.11.8)
   - git
   - ansible
   - yq
   - kubectl
   - vscode (recommended)

2. Run automation playbook that will scaffold project for you:

   `ansible-playbook setup.ansible.yaml`

3. Activate virtualenv

   - in your IDE
   - in your shell: `cd todo-api && poetry shell`

4. Access todo-api service: `http://localhost:30000`

## Admin processes

`./execute.sh -m pytest`
`./execute.sh -m pytest -n 4`
`./execute.sh src/manage.py migrate`
`./execute.sh src/manage.py makemigrations`

## Tech Stack

- backend:
  - django, django-ninja,
  - pytest, pytest-django,
  - uvicorn
- kubernetes
- ansible

## Setup automation tests

This commands will run setup automation inside ubuntu container

```sh
docker build -f tests/project-setup/ubuntu/Dockerfile -t ubuntu-test .
docker run -it --mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock \
   --mount type=bind,source="$(pwd)",target="$(pwd)" \
   --network host \
   ubuntu-test sh -c "cd $(pwd) && ansible-playbook setup.ansible.yaml"
```
