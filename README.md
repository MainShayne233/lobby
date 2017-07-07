# Lobby

In memory lobby that handles members and their states.

[![Build Status](https://travis-ci.org/MainShayne233/lobby.svg?branch=master)](https://travis-ci.org/MainShayne233/lobby)
[![Coverage Status](https://coveralls.io/repos/github/MainShayne233/lobby/badge.svg?branch=master)](https://coveralls.io/github/MainShayne233/lobby?branch=master)
[![Code Climate](https://codeclimate.com/github/MainShayne233/lobby/badges/gpa.svg)](https://codeclimate.com/github/MainShayne233/lobby)
[![Hex Version](http://img.shields.io/hexpm/v/lobby.svg?style=flat)](https://hex.pm/packages/lobby)



## Install
In your `mix.exs` file, add `{:lobby, "~> 0.0.1"}` to the `deps`, like so:
```elixir
defp deps do
  [
    {:lobby, "~> 0.0.1"},
  ]
end
```
Then run `mix deps.get`


## Use

Example of creating a lobby and handling members
```elixir

# creating a named lobby
{:ok, _lobby} = Lobby.start_link(:my_lobby)

# creating a new member of the lobby
{:ok, {member_id, member}} = Lobby.new_member(:my_lobby)

# updating a lobby member
Lobby.update_member(:my_lobby, member_id, %{some_cool: "state"})

# retrieving a lobby member
Lobby.get_member(:my_lobby, member_id)
#=>
{:ok, %{some_cool: "state"}}

# retrieving entire lobby
Lobby.lobby(:my_lobby)
#=>
{:ok, %{
  0 => %{some_cool: "state"},
}}

# removing a lobby member
Lobby.remove_member(:my_lobby, member_id)

Lobby.get_member(:my_lobby, member_id)
#=>
{:error, "No member for id"}
```

## Use with Supervisor

Since `Lobby` is a GenServer, you can use it with Supervisor, and can be easily added to any already existing Supervisor module.
```elixir
defmodule YourApp do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(Lobby, [:my_lobby_name]),
    ]

    opts = [strategy: :one_for_one, name: YourApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
```

Then you can just refer to your lobby by `:my_lobby_name` throughout your application.

## Roadmap

- Add different unique key options (currently just an integer)
- Track member count for easy access to the count

## Contributing

I am extremely happy to receive pull requests for any bug fixes, new features, enhancements, etc. If you want to make a change, and you're not sure how to proceed, feel free to leave an issue on this repo explaining that and I'll totally work with you on making the change.
