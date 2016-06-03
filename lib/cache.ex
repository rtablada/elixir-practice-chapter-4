defmodule Metex.Cache do
  use GenServer

  @name MC

  # Public API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts ++ [name: MC])
  end

  def write(key, value) do
    GenServer.call @name, {:write, {key, value}}
  end

  def read(key) do
    GenServer.call @name, {:read, key}
  end

  def exist?(key) do
    GenServer.call @name, {:exist?, key}
  end

  def delete(key) do
    GenServer.cast @name, {:delete, key}
  end

  def clear do
    GenServer.cast @name, :clear
  end

  # GenServer Hooks

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_call({:write, {key, value}}, _from, state) do
    {:reply, :ok, change_value(state, key, value)}
  end

  def handle_call({:read, key}, _from, state) do
    {:reply, Map.get(state, key), state}
  end

  def handle_call({:exist?, key}, _from, state) do
    {:reply, Map.has_key?(state, key), state}
  end

  def handle_cast({:delete, key}, state) do
    {:noreply, Map.drop(state, key)}
  end

  def handle_cast(:clear, _state) do
    {:noreply, %{}}
  end

  ## Helpers
  defp change_value(old_state, loc, value) do
    case Map.has_key?(old_state, loc) do
      true ->
        Map.update!(old_state, loc, value)
      false ->
        Map.put_new(old_state, loc, value)
    end
  end
end
