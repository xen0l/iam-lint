FROM python:3-alpine

COPY requirements.txt /requirements.txt
RUN apk --no-cache add bash && \
    pip --no-cache-dir install -r /requirements.txt

COPY iam-lint /iam-lint

ENTRYPOINT ["/iam-lint"]

