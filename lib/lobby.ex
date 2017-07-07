defmodule Lobby do
  use GenServer

  @moduledoc """
  This module defines the GenServer that is the lobby GenServer
  The lobby's sole purpose is to manage members, their ids, and thei current state.
  """

  # PUBLIC API

  @doc """
  Starts and returns a Lobby GenServer process
  First argument is the name you want to give the lobby, if any.
  """
  @spec start_link(atom) :: {:ok, pid} | {:error, String.t}
  def start_link(name \\ nil) do
    GenServer.start_link(__MODULE__, %{name: name}, name: name)
  end


  @doc """
  Creates and returns a new member id and state

  ## Example

      iex> Lobby.new_member(:test_lobby)
      {:ok, {1, %{}}}
  """
  @spec new_member(pid | atom) :: {:ok, {number, map}} | {:error, String.t}
  def new_member(lobby) do
    GenServer.call(lobby, :new_member)
  end


  @doc """
  Returns the state for the given member id

  ## Example
      iex> Lobby.get_member(:test_lobby, 0)
      {:ok, %{}}
  """
  @spec get_member(pid | atom, number) :: {:ok, map} | {:error, String.t}
  def get_member(lobby, member_id) do
    GenServer.call(lobby, {:get_member, member_id})
  end


  @doc """
  Returns the map that represents the entire lobby

  ## Examples

      iex> Lobby.lobby(:test_lobby)
      {:ok, %{0 => %{}}}
  """
  @spec lobby(pid | atom) :: {:ok, map}
  def lobby(lobby) do
    GenServer.call(lobby, :lobby)
  end


  @doc """
  Removes the memmber for the given member_id from the lobby

  ## Example
      iex> Lobby.remove_member(:test_lobby, 0)
      iex> Lobby.get_member(:test_lobby, 0)
      {:error, "No member for id"}
  """
  @spec remove_member(pid | atom, number) :: :ok
  def remove_member(lobby, member_id) do
    GenServer.cast(lobby, {:remove_member, member_id})
  end


  @doc """
  Updates the member for the given id

  ## Example
      iex> Lobby.update_member(:test_lobby, 0, %{sweet: :state})
      iex> Lobby.get_member(:test_lobby, 0)
      {:ok, %{sweet: :state}}
  """
  @spec update_member(pid | atom, number, map) :: :ok
  def update_member(lobby, member_id, member) do
    GenServer.cast(lobby, {:update_member, member_id, member})
  end


  def init(options) do
    {:ok, initial_state(options)}
  end


  def handle_call(:new_member, _from, state) do
    {:ok, member, last_memeber_id} = create_new_member(state)
    {:reply, {:ok, member}, %{state | last_memeber_id: last_memeber_id}}
  end


  def handle_call({:get_member, member_id}, _from, state) do
    {:reply, get_member_state(state, member_id), state}
  end


  def handle_call(:lobby, _from, state) do
    lobby = get_lobby(state)
    {:reply, {:ok, lobby}, state}
  end


  def handle_cast({:remove_member, member_id}, state) do
    add_spare_id(state, member_id)
    remove_member_state(state, member_id)
    {:noreply, state}
  end


  def handle_cast({:update_member, member_id, member}, state) do
    set_member_state(state, member_id, member)
    {:noreply, state}
  end



  defp initial_state(options = %{name: name}) do
    %{
      table: new_table(name),
      options: options,
      last_memeber_id: :not_created_yet,
    }
  end


  ## LOBBY


  defp get_lobby(%{table: table}), do: get(table, :lobby)


  ## MEMBER


  defp create_new_member(state) do
    {:ok, new_member_id, last_memeber_id} = new_member_id(state)
    set_member_state(state, new_member_id, %{})
    {:ok, {new_member_id, %{}}, last_memeber_id}
  end


  defp set_member_state(state = %{table: table}, member_id, member) do
    updated_lobby =
      state
      |> get_lobby
      |> Map.put(member_id, member)

    set(table, :lobby, updated_lobby)
  end


  defp remove_member_state(state = %{table: table}, member_id) do
    updated_lobby =
      state
      |> get_lobby
      |> Map.drop([member_id])

    set(table, :lobby, updated_lobby)
  end


  defp get_member_state(state, member_id) do
    state
    |> get_lobby
    |> Map.get(member_id)
    |> case do
      nil -> {:error, "No member for id"}
      :removed -> {:error, "No member for id"}
      member_state -> {:ok, member_state}
    end
  end


  defp new_member_id(%{last_memeber_id: :not_created_yet}), do: {:ok, 0, 0}


  defp new_member_id(state = %{last_memeber_id: last_id, table: table}) do
    spare_ids(state)
    |> case do
      [] ->
        new_id = last_id + 1
        {:ok, new_id, new_id}
      [spare_id | rest] ->
        set(table, :spare_ids, rest)
        {:ok, spare_id, last_id}
    end
  end


  defp spare_ids(%{table: table}) do
    get(table, :spare_ids)
  end


  defp add_spare_id(state = %{table: table}, spare_id) do
    updated_spare_ids = [spare_id | spare_ids(state)]
    set(table, :spare_ids, updated_spare_ids)
  end


  ## TABLE


  defp new_table(name) do
    table =
      "#{name}_table"
      |> String.to_atom
      |> :ets.new([:ordered_set, :protected, :named_table])

    table
    |> set(:spare_ids, [])
    |> set(:lobby, %{})
  end


  defp get(table, key) do
    table
    |> :ets.lookup(key)
    |> case do
      [] -> nil
      [{^key, value}] -> value
    end
  end


  defp set(table, key, value) do
    table |> :ets.insert({key, value})
    table
  end
end
