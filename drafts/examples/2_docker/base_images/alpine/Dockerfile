#############################################################################
ARG VERSION
FROM alpine:${VERSION} as base

# Setup app dir and user
RUN mkdir -p /app && \
    addgroup -g 900 appuser && \
    adduser -u 900 -S appuser -s /bin/sh && \
    adduser appuser appuser && \
    chown -R appuser:appuser /app && \
    apk add --no-cache bash
WORKDIR /app
USER appuser

#############################################################################
FROM base as shell

USER root
RUN apk add --no-cache ca-certificates sudo vim less build-base bash curl jq git && \
    printf "%s\n" "appuser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
USER appuser
