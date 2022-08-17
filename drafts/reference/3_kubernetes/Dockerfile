FROM debian:stretch-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends watch

COPY ./bin/with_env_exec /usr/local/bin/with_env_exec
