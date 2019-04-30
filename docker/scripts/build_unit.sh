#!/usr/bin/env bash

apk --no-cache add build-base ruby-dev openssl-dev

# Create a directory for nginx-unit state files
mkdir -p /opt/unit/state
mkdir -p /var/log/unit

git clone https://github.com/nginx/unit /tmp/unit && \
  cd /tmp/unit && \
  git fetch && \
  git fetch --tags && \
  git checkout 1.8.0

./configure \
  --openssl \
  --prefix=/opt/unit \
  --state=/opt/unit/state
./configure ruby

make && make install
