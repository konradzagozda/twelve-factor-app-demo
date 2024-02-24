FROM python:3.11-alpine

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

RUN apk update && \
    apk add --no-cache postgresql-libs gcc musl-dev postgresql-dev

WORKDIR /app

COPY requirements.txt ./

RUN python -m venv /opt/venv && \
    /opt/venv/bin/python -m pip install --no-cache-dir -r requirements.txt
    
COPY . ./

ENTRYPOINT ["/opt/venv/bin/python"]
CMD ["-m", "uvicorn", "--host", "0.0.0.0", "config.asgi:application"]