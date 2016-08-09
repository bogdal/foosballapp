FROM ubuntu:latest

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN \
 apt-get -y update && \
 apt-get install -y apt-transport-https

RUN \
 apt-key adv --keyserver keyserver.ubuntu.com --recv 68576280 && \
 echo 'deb https://deb.nodesource.com/node_5.x jessie main' | tee /etc/apt/sources.list.d/nodesource.list && \
 echo 'deb-src https://deb.nodesource.com/node_5.x jessie main' | tee -a /etc/apt/sources.list.d/nodesource.list

RUN \
 apt-get -y update && \
 apt-get install -y nodejs curl wget git make && \
 apt-get clean

RUN \
 wget http://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && \
 dpkg -i erlang-solutions_1.0_all.deb && \
 apt-get update

RUN \
 apt-get install -y elixir erlang-dev erlang-parsetools && \
 rm erlang-solutions_1.0_all.deb

ENV PHOENIX_VERSION 1.2.0

RUN mix archive.install --force https://github.com/phoenixframework/archives/raw/master/phoenix_new-$PHOENIX_VERSION.ez

ADD . /app
WORKDIR /app

RUN mix local.hex --force
RUN mix local.rebar

RUN npm install && npm install --save-dev babel-cli babel-preset-es2015

EXPOSE 4000
CMD mix deps.get && elixir -S mix phoenix.server
