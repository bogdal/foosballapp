FROM elixir:latest

ENV PHOENIX_VERSION 1.2.0

RUN mix archive.install --force https://github.com/phoenixframework/archives/raw/master/phoenix_new-$PHOENIX_VERSION.ez

RUN mix local.hex --force
RUN mix local.rebar

ADD . /app
WORKDIR /app

EXPOSE 4000
ENV PORT 4000

CMD mix do deps.get, compile && elixir -S mix phoenix.server
