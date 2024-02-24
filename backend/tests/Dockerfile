# extends src/Dockerfile, used to run jobs and tests
FROM backend

WORKDIR /app
COPY requirements.dev.txt ./tests/

RUN /opt/venv/bin/python -m pip install --no-cache-dir -r ./tests/requirements.dev.txt

COPY . ./tests/

ENV PYTHONPATH "src:tests"
ENV DJANGO_SETTINGS_MODULE "config.settings"