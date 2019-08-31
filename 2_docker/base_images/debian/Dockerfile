#############################################################################
ARG VERSION
FROM debian:${VERSION} as base

# Setup app dir and user
RUN mkdir -p /app && \
    groupadd -g 900 app && \
    useradd -r -u 900 -g app app -m -s /bin/bash && \
    chown -R app:app /app
WORKDIR /app

#############################################################################
FROM base as shell

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates sudo vim less build-essential curl jq git man && \
    update-ca-certificates && \
    adduser app sudo && \
    printf "%s\n" "app ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
