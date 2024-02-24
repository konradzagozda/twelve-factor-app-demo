FROM python:3.11-alpine

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

RUN apk update && \
    apk add --no-cache postgresql-libs gcc musl-dev postgresql-dev && \
    adduser -D apprunner

USER apprunner
WORKDIR /app

COPY requirements.txt ./

RUN python -m venv venv && \
    venv/bin/python -m pip install --no-cache-dir -r requirements.txt
    

USER apprunner
COPY . ./

ENTRYPOINT ["venv/bin/python", "-m", "uvicorn", "--host", "0.0.0.0", "config.asgi:application"]
