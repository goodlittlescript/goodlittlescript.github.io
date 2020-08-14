FROM debian:stretch-slim as shell

# Setup appuser
RUN groupadd -g 1001 appuser && \
    useradd -r -u 1001 -g appuser appuser -m -s /bin/bash

RUN mkdir -p /app /etc/gems && \
    chown appuser:appuser /app /etc/gems && \
    apt-get update && \
    apt-get install -y ruby-full build-essential zlib1g-dev jq curl vim parallel && \
    gem install bundler -v 2.1.4 && \
    curl -o /usr/local/bin/ts -L https://raw.githubusercontent.com/thinkerbot/ts/v2.0.3/bin/ts && \
    chmod +x /usr/local/bin/ts && \
    curl -L -o /usr/local/bin/yajsv https://github.com/neilpa/yajsv/releases/download/v1.3.0/yajsv.linux.amd64 && \
    chmod +x /usr/local/bin/yajsv 

WORKDIR /app
ENV GEM_HOME="/etc/gems"
ENV PATH="/app/bin:/etc/gems/bin:$PATH"

COPY --chown=appuser:appuser Gemfile Gemfile.lock /app/
USER appuser
