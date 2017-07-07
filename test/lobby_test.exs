defmodule LobbyTest do
  use ExUnit.Case
  doctest Lobby

  setup do
    Lobby.start_link(:test_lobby)
    :ok
  end


  test "start_link/1 will create a Lobby GenServer with a name" do
    {:ok, lobby} = Lobby.start_link(:my_cool_lobby)
    assert Process.alive?(lobby)
    assert :my_cool_lobby |> Process.whereis |> Process.alive?
  end


  test "new_member/1 should return a {:ok, {member_id, member_state}}" do
    {:ok, {member_id, state}} = Lobby.new_member(:test_lobby)
    assert member_id == 0
    assert state == %{}

    {:ok, {member_id, state}} = Lobby.new_member(:test_lobby)
    assert member_id == 1
    assert state == %{}
  end


  test "get_member/2 should return {:ok, {member_id, member_state}} for valid member_id" do
    {:ok, {member_id, state}} = Lobby.new_member(:test_lobby)
    assert Lobby.get_member(:test_lobby, member_id) == {:ok, state}
  end


  test "get_member/2 should return {:error, error} for non-existent member" do
    assert Lobby.get_member(:test_lobby, 3) == {:error, "No member for id"}
  end


  test "remove_member/2 should remove the member from the table" do
    {:ok, {member_id, _state}} = Lobby.new_member(:test_lobby)
    :ok = Lobby.remove_member(:test_lobby, member_id)
    assert Lobby.get_member(:test_lobby, member_id) == {:error, "No member for id"}
  end
end
