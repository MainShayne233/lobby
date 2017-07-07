# Lobby

In memory handling of users with unique ids and state

[![Build Status](https://travis-ci.org/MainShayne233/lobby.svg?branch=master)](https://travis-ci.org/MainShayne233/lobby)
[![Coverage Status](https://coveralls.io/repos/github/MainShayne233/lobby/badge.svg?branch=master)](https://coveralls.io/github/MainShayne233/lobby?branch=master)
[![Code Climate](https://codeclimate.com/github/MainShayne233/executor/badges/gpa.svg)](https://codeclimate.com/github/MainShayne233/executor)


## Progress

You can create and get users:
```elixir
{:ok, _lobby} = Lobby.start_link(:my_lobby)

Lobby.new_member(:my_lobby)
#=>
{:ok, {0, %{}}}

Lobby.new_member(:my_lobby)
#=>
{:ok, {1, %{}}}

Lobby.get_member(:my_lobby, 0)
#=>
{:ok, %{}}
```

## Roadmap

- Update member state
- Remove members
