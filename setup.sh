#!/bin/bash
set -x

cd backend
poetry export -f requirements.txt --output requirements.txt