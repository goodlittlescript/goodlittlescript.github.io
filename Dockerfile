FROM debian:stretch-slim as shell

RUN mkdir -p /app && \
    apt-get update && \
    apt-get install -y ruby-full build-essential zlib1g-dev && \
    gem install bundler -v 2.1.4

WORKDIR /app
ENV GEM_HOME="$HOME/gems"
ENV PATH="/app/bin:$HOME/gems/bin:$PATH"

COPY Gemfile Gemfile.lock /app/
RUN bundle install
