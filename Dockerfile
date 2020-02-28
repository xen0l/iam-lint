FROM python:3-slim-buster

COPY requirements.txt /requirements.txt
RUN pip --no-cache-dir install -r /requirements.txt

COPY iam-lint /iam-lint

ENTRYPOINT ["/iam-lint"]
