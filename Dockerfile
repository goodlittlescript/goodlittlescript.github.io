FROM python:3.7-buster

# Setup appuser and app dir
RUN groupadd -g 1001 appuser && \
    useradd -r -u 1001 -g appuser appuser -m -s /bin/bash && \
    mkdir -p /app && \
    chown appuser:appuser /app
WORKDIR /app

# Install project dependencies
COPY ./requirements.txt /app
RUN pip install -r requirements.txt

USER appuser
