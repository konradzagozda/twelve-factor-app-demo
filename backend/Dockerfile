FROM python:3.11-alpine

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# psycopg2 dependencies
RUN \
    apk update && \
    apk add --no-cache postgresql-libs && \
    apk add --no-cache gcc musl-dev postgresql-dev

RUN adduser -D apprunner
USER apprunner
WORKDIR /app

COPY requirements.txt ./

RUN pip install --no-cache-dir -r requirements.txt --no-cache-dir
    

USER apprunner
COPY . ./

ENTRYPOINT ["python", "-m", "uvicorn", "--host", "0.0.0.0", "config.asgi:application"]
