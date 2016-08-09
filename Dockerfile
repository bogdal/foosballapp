FROM elixir:latest

ENV PHOENIX_VERSION 1.2.0

RUN mix archive.install --force https://github.com/phoenixframework/archives/raw/master/phoenix_new-$PHOENIX_VERSION.ez

ADD . /app
WORKDIR /app

RUN mix local.hex --force
RUN mix local.rebar

EXPOSE 4000
CMD mix deps.get && elixir -S mix phoenix.server
