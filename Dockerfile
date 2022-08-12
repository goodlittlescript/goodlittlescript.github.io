FROM python:3.7-buster

# Setup appuser and app dir
RUN groupadd -g 1001 appuser && \
    useradd -r -u 1001 -g appuser appuser -m -s /bin/bash && \
    mkdir -p /app && \
    chown appuser:appuser /app
WORKDIR /app

# Install project dependencies
COPY ./requirements.txt /app
RUN pip install -r requirements.txt

# Install development dependencies
# * curl bash gawk diffutils expect for ts
RUN apt-get update && \
    apt-get install -y curl jq && \
    curl -o /usr/local/bin/ts -L https://raw.githubusercontent.com/thinkerbot/ts/v2.0.3/bin/ts && \
    chmod +x /usr/local/bin/ts && \
    curl -L -o /usr/local/bin/yajsv https://github.com/neilpa/yajsv/releases/download/v1.3.0/yajsv.linux.amd64 && \
    chmod +x /usr/local/bin/yajsv

USER appuser
