ARG ELIXIR_VERSION=1.14.5
ARG OTP_VERSION=26.2.5.9
ARG DEBIAN_VERSION=bullseye-20250224-slim

ARG BUILDER_IMAGE="hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}"

FROM ${BUILDER_IMAGE} as os

RUN apt-get update && apt-get install -f -y build-essential \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*

# Install hex package manager
# Bypass installation confirmation using --force
RUN mix local.hex --force && mix local.rebar --force

WORKDIR /app

# MIX DEPENDENCIES STAGE --------------------------------------
FROM os AS mix-deps

# Copy mix file
COPY mix.* ./

# Install and compile
RUN HEX_HTTP_CONCURRENCY=1 HEX_HTTP_TIMEOUT=120 mix deps.get
RUN mix deps.compile

# FINAL STAGE -------------------------------------------------
FROM mix-deps

# set build ENV
ENV MIX_ENV="${MIX_ENV}"
ENV SECRET_KEY_BASE="${SECRET_KEY_BASE}"

COPY . ./

CMD ["mix", "phx.server"]
