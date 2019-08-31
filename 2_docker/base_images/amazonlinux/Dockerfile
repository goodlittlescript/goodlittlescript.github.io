#############################################################################
ARG VERSION
FROM amazonlinux:${VERSION} as base

# Setup app dir and user
RUN yum update -y && \
    yum install -y shadow-utils && \
    mkdir -p /app && \
    groupadd -g 900 appuser && \
    useradd -r -u 900 -g appuser appuser -m -s /bin/bash && \
    chown -R appuser:appuser /app && \
    yum clean all && \
    rm -rf /var/cache/yum
WORKDIR /app
USER appuser

#############################################################################
FROM base as shell

USER root
RUN yum update -y && \
    yum install -y sudo vim less make automake gcc gcc-c++ kernel-devel jq git man && \
    printf "%s\n" "appuser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
USER appuser
