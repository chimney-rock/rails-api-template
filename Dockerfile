FROM alpine:edge AS base

ENV GEM_HOME /usr/local/bundle
ENV BUNDLE_PATH="$GEM_HOME" \
    BUNDLE_BIN="$GEM_HOME/bin" \
    BUNDLE_SILENCE_ROOT_WARNING=1 \
    BUNDLE_APP_CONFIG="$GEM_HOME"
ENV PATH $BUNDLE_BIN:$PATH
ENV INSTALL_PATH /app/current
WORKDIR $INSTALL_PATH

COPY ./docker/scripts /scripts

RUN apk --no-cache add bash && \
  /scripts/base_packages.sh

###################################################################################################
# Create a container for building NGINX-UNIT.
# Important: Anything in this stage NOT copied into the final container will be DISCARDED!
###################################################################################################
FROM base AS build-unit

RUN /scripts/build_unit.sh

###################################################################################################
# Create a container for installing gems & any necessary development packages.
# Important: Anything in this stage NOT copied into the final container will be DISCARDED!
###################################################################################################
FROM base AS bundle-install

# This container image is setup for production builds by default
# NOTE: This argument is overridden inside `docker-compose.yml` for development!
ARG BUNDLE_WITHOUT='development test'

WORKDIR $INSTALL_PATH

COPY Gemfile Gemfile.lock ./

# Install necessary packages required for bundler to install the project dependencies
RUN apk --no-cache add \
  postgresql-dev \
  libxml2-dev \
  libxslt-dev \
  libffi-dev \
  build-base \
  ruby-dev

# Install gem dependencies and skip any groups specified via `BUNDLE_WITHOUT`
RUN bundle install --jobs 20 --without $BUNDLE_WITHOUT

###################################################################################################
###################################################################################################

FROM base AS final-destination

COPY --from=bundle-install $GEM_HOME $GEM_HOME
COPY --from=build-unit /opt/unit/ /opt/unit/

ADD . .
STOPSIGNAL SIGTERM

COPY ./docker/unit/conf.json /opt/unit/state/conf.json
CMD ["/opt/unit/sbin/unitd", "--no-daemon", "--control", "0.0.0.0:8080", "--state", "/opt/unit/state", "--log", "/app/current/log/unit.log"]
