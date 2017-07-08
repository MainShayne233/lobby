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
  Returns a list of all members of the lobby

  ## Example

      iex> Lobby.members(:test_lobby)
      {:ok, [%{}]}
  """
  @spec members(pid | atom) :: {:ok, [map]}
  def members(lobby) do
    GenServer.call(lobby, :members)
  end


  @doc """
  Returns the map that represents the entire lobby

  ## Examples

      iex> Lobby.lobby(:test_lobby)
      {:ok, [{0, %{}}]}
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
    {:ok, member, spare_ids, last_member_id} = create_new_member(state)
    updated_state = %{state | spare_ids: spare_ids, last_member_id: last_member_id}
    {:reply, {:ok, member}, updated_state}
  end


  def handle_call({:get_member, member_id}, _from, state) do
    {:reply, get_member_state(state, member_id), state}
  end


  def handle_call(:members, _from, state) do
    {:reply, {:ok, get_all_member_states(state)}, state}
  end


  def handle_call(:lobby, _from, state) do
    lobby = get_lobby(state)
    {:reply, {:ok, lobby}, state}
  end


  def handle_cast({:remove_member, member_id}, state) do
    remove_member_state(state, member_id)
    {:noreply, %{state | spare_ids: [member_id | state.spare_ids]}}
  end


  def handle_cast({:update_member, member_id, member}, state) do
    set_member_state(state, member_id, member)
    {:noreply, state}
  end



  defp initial_state(options = %{name: name}) do
    %{
      table: new_table(name),
      options: options,
      spare_ids: [],
      last_member_id: :not_created_yet,
    }
  end


  ## LOBBY


  defp get_lobby(%{table: table}), do: all(table)


  ## MEMBER


  defp create_new_member(%{table: table, last_member_id: :not_created_yet}) do
    set(table, 0, %{})
    {:ok, {0, %{}}, [], 0}
  end


  defp create_new_member(%{table: table, spare_ids: [], last_member_id: last_member_id}) do
    new_member_id = last_member_id + 1
    set(table, new_member_id, %{})
    {:ok, {new_member_id, %{}}, [], new_member_id}
  end


  defp create_new_member(%{table: table, spare_ids: [spare_id | rest], last_member_id: last_member_id}) do
    set(table, spare_id, %{})
    {:ok, {spare_id, %{}}, rest, last_member_id}
  end


  defp set_member_state(%{table: table}, member_id, member) do
    set(table, member_id, member)
  end


  defp remove_member_state(%{table: table}, member_id) do
    remove(table, member_id)
  end


  defp get_member_state(%{table: table}, member_id) do
    get(table, member_id)
    |> case do
      nil -> {:error, "No member for id"}
      :removed -> {:error, "No member for id"}
      member_state -> {:ok, member_state}
    end
  end


  defp get_all_member_states(%{table: table}) do
    table
    |> values
  end


  defp new_table(name) do
    "#{name}_table"
    |> String.to_atom
    |> :ets.new([:ordered_set, :protected, :named_table])
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


  defp remove(table, key) do
    table |> :ets.delete(key)
    table
  end


  defp all(table) do
    table |> :ets.match_object({:"$1", :"$2"})
  end


  defp values(table) do
    table
    |> :ets.match({:"_", :"$1"})
    |> List.flatten
  end
end
