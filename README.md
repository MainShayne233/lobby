# Lobby

In memory handling of users with unique ids and state

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
