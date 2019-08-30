#############################################################################
FROM debian:stable-slim as base

# Setup project dir
RUN mkdir /app
WORKDIR /app

#############################################################################
FROM base as app

# Add code
COPY . /app

#############################################################################
FROM base as shell
