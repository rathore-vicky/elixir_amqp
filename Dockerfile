FROM hexpm/elixir:1.13.3-erlang-24.2-alpine-3.15.0 AS build

ENV APP_VSN="0.0.0"

WORKDIR /app

COPY mix.exs mix.lock ./
ADD config/ config

RUN mix local.hex --force && \
    mix archive.install hex phx_new 1.5.7 --force && \
    mix local.rebar --force && \
    mix deps.get && \
    mix deps.compile && \
    mix compile
  
ADD priv priv/
ADD lib lib/


RUN apk update && \
  apk add --no-cache \
  git \
  bash \
  libgcc \
  libstdc++ \
  ca-certificates \
  ncurses-libs \
  wget \
  openssl


EXPOSE 4000

COPY entrypoint.sh /usr/local/bin
RUN ln -s usr/local/bin/entrypoint.sh /

ENTRYPOINT ["entrypoint.sh"]
