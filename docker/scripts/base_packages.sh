#!/usr/bin/env bash

# Disable documentation, install messages and suggestions when installing gems
mkdir -p /usr/local/etc && \
  { \
		echo 'install: --no-document --no-post-install-message --no-suggestions'; \
		echo 'update: --no-document --no-post-install-message --no-suggestions'; \
    echo 'gem: --no-document --no-post-install-message --no-suggestions'; \
	} >> /etc/gemrc && \
  chmod uog+r /etc/gemrc

addgroup -g 1000 -S app && adduser -u 1000 -S app -G app

mkdir -p ${GEM_HOME}
mkdir -p ${BUNDLE_BIN}
mkdir -p ${INSTALL_PATH}

chown -R app:app "${GEM_HOME}" "${BUNDLE_BIN}" "${INSTALL_PATH}"

# Install base packages
apk --no-cache add \
  postgresql-client \
  ruby-bigdecimal \
  ca-certificates \
  ruby-bundler \
  libstdc++ \
  ruby-json \
  ruby-irb \
  ruby-etc \
  ruby-ffi \
  libressl \
  openssl \
  libxml2 \
  ruby \
  git
