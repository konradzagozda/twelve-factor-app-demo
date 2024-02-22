#!/bin/bash

# Start docker
start-docker.sh

# commands
sleep 60
cd project && ansible-playbook setup.yaml
