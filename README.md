# Lobby

In memory handling of users with unique ids and state

[![Build Status](https://travis-ci.org/MainShayne233/lobby.svg?branch=master)](https://travis-ci.org/MainShayne233/lobby)
[![Coverage Status](https://coveralls.io/repos/github/MainShayne233/lobby/badge.svg?branch=master)](https://coveralls.io/github/MainShayne233/lobby?branch=master)
[![Code Climate](https://codeclimate.com/github/MainShayne233/executor/badges/gpa.svg)](https://codeclimate.com/github/MainShayne233/executor)


## Install
In your `mix.exs` file, add `{:lobby, github: "MainShayne233/lobby"}` to the `deps`, like so:
```elixir
defp deps do
  [
    {:lobby, github: "MainShayne233/lobby"},
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

## Roadmap

- Add different unique key options (currently just an integer)
- Track member count for easy access to the count
