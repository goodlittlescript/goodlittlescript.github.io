FROM debian:stretch-slim as shell

# Setup appuser
RUN groupadd -g 1001 appuser && \
    useradd -r -u 1001 -g appuser appuser -m -s /bin/bash

RUN mkdir -p /app /etc/gems && \
    chown appuser:appuser /app /etc/gems && \
    apt-get update && \
    apt-get install -y ruby-full build-essential zlib1g-dev && \
    gem install bundler -v 2.1.4

WORKDIR /app
ENV GEM_HOME="/etc/gems"
ENV PATH="/app/bin:/etc/gems/bin:$PATH"

COPY --chown=appuser:appuser Gemfile Gemfile.lock /app/
USER appuser
RUN bundle install
