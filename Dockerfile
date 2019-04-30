FROM alpine:edge AS base

ENV GEM_HOME /usr/local/bundle
ENV BUNDLE_PATH="$GEM_HOME" \
    BUNDLE_BIN="$GEM_HOME/bin" \
    BUNDLE_SILENCE_ROOT_WARNING=1 \
    BUNDLE_APP_CONFIG="$GEM_HOME"
ENV PATH $BUNDLE_BIN:$PATH
ENV INSTALL_PATH /app/current
WORKDIR $INSTALL_PATH

RUN apk --no-cache add \
  postgresql-client \
  ruby-bigdecimal \
  ruby-io-console \
  ca-certificates \
  ruby-bundler \
  libstdc++ \
  ruby-json \
  ruby-irb \
  ruby-etc \
  ruby-ffi \
  libressl \
  libxml2 \
  ruby \
  bash \
  git
