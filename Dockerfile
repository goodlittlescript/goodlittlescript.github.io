FROM ubuntu:bionic as ubuntu

RUN mkdir -p /app
WORKDIR /app

# Add back documentation and other nice things
RUN yes | unminimize && \
    apt-get install -y man-db && \
    rm -r /var/lib/apt/lists/*

# Development dependencies and tools
# * curl
# * jq
# * ts
RUN apt-get update && \
    apt-get install -y curl jq && \
    curl -o /usr/local/bin/ts -L https://raw.githubusercontent.com/thinkerbot/ts/v2.0.2/bin/ts && \
    chmod +x /usr/local/bin/ts
