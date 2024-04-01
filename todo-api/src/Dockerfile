FROM python:3.12-alpine

ARG BRANCH="local"
ARG COMMIT="local"
ARG TAG="local"

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

RUN apk update && \
    apk add --no-cache postgresql-libs gcc musl-dev postgresql-dev

WORKDIR /app/src

COPY requirements.txt ./

RUN python -m venv /opt/venv && \
    /opt/venv/bin/python -m pip install --no-cache-dir -r requirements.txt

COPY . ./

LABEL "git.branch"="$BRANCH" "git.commit"="$COMMIT"
ENV BRANCH="$BRANCH" COMMIT="$COMMIT" TAG="$TAG"

ENTRYPOINT ["/opt/venv/bin/python"]
CMD ["-m", "uvicorn", "--host", "0.0.0.0", "config.asgi:application"]