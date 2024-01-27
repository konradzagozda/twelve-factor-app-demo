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

## Tech Stack

- backend: django, django-ninja, pytest, uvicorn
- kubernetes for local deployment

## Features

- Dockerfiles built with best practice in mind: minimal size, security, single Dockerfile for every environment
