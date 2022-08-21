#!/bin/bash

str=`date -Ins | md5sum`
# name=${str:0:10}

mix deps.get
mix deps.compile

mix phx.digest
mix ecto.create
mix ecto.migrate

elixir --sname elixir_amqp@localhost --cookie monster -S mix phx.server
