#############################################################################
FROM debian:stable-slim as base

# Setup app dir and user
RUN mkdir -p /app && \
    groupadd -g 900 appuser && \
    useradd -r -u 900 -g appuser appuser -m -s /bin/bash && \
    chown -R appuser:appuser /app
WORKDIR /app

#############################################################################
FROM base as app

COPY . /app
USER appuser

#############################################################################
FROM base as shell

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates sudo vim less build-essential curl git man && \
    adduser appuser sudo && \
    printf "%s\n" "appuser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
USER appuser
