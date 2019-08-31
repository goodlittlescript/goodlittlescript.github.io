#############################################################################
ARG VERSION
FROM alpine:${VERSION} as base

# Setup app dir and user
RUN mkdir -p /app && \
    addgroup -g 900 app && \
    adduser -u 900 -S app -s /bin/sh && \
    adduser app app && \
    chown -R app:app /app && \
    apk add --no-cache bash
WORKDIR /app

#############################################################################
FROM base as shell

RUN apk add --no-cache ca-certificates sudo vim less build-base bash curl jq git && \
    printf "%s\n" "app ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
