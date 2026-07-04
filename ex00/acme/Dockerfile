# syntax=docker/dockerfile:1
# Production image for Kamal. Build/run by hand with:
#   docker build -t acme .
#   docker run -d -p 3000:3000 -e RAILS_MASTER_KEY=<config/master.key> --name acme acme

ARG RUBY_VERSION=3.0.2
FROM ruby:$RUBY_VERSION-slim AS base

WORKDIR /app

# Runtime packages only (libpq5 is the pg runtime lib; nodejs runs asset JS).
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends curl libpq5 nodejs && \
    rm -rf /var/lib/apt/lists/*

ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test"


# ---- build stage -----------------------------------------------------------
FROM base AS build

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
      build-essential git libpq-dev libyaml-dev pkg-config nodejs && \
    rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock ./
RUN gem install bundler && \
    bundle install && \
    rm -rf ~/.bundle "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

COPY . .

# Precompile bootsnap for faster boot.
RUN bundle exec bootsnap precompile app/ lib/ || true

# Precompile assets without needing the real master key.
RUN SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile


# ---- final stage -----------------------------------------------------------
FROM base

# Non-root runtime user.
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash

COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build --chown=rails:rails /app /app

USER 1000:1000

ENTRYPOINT ["/app/bin/docker-entrypoint"]

EXPOSE 3000
CMD ["bin/rails", "server", "-b", "0.0.0.0", "-p", "3000"]
