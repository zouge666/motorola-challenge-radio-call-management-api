defmodule RadioCallApi.FloorControl.MemoryStore do
  @moduledoc """
  In-memory floor store used for local development and tests.
  """

  use GenServer

  alias RadioCallApi.FloorControl.Store

  @behaviour Store

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{floors: %{}}, name: __MODULE__)
  end

  @impl Store
  def claim(group_id, user_id, _priority, _lease_ms) do
    GenServer.call(__MODULE__, {:claim, group_id, user_id})
  end

  @impl Store
  def release(group_id, user_id) do
    GenServer.call(__MODULE__, {:release, group_id, user_id})
  end

  def reset! do
    GenServer.call(__MODULE__, :reset)
  end

  @impl true
  def init(state), do: {:ok, state}

  @impl true
  def handle_call({:claim, group_id, user_id}, _from, state) do
    case Map.get(state.floors, group_id) do
      nil ->
        state = put_in(state, [:floors, group_id], user_id)
        {:reply, {:ok, :granted}, state}

      ^user_id ->
        {:reply, {:ok, :renewed}, state}

      holder ->
        {:reply, {:error, {:occupied, holder}}, state}
    end
  end

  @impl true
  def handle_call({:release, group_id, user_id}, _from, state) do
    case Map.get(state.floors, group_id) do
      ^user_id ->
        state = update_in(state.floors, &Map.delete(&1, group_id))
        {:reply, :ok, state}

      _ ->
        {:reply, {:error, :not_holder}, state}
    end
  end

  @impl true
  def handle_call(:reset, _from, _state) do
    {:reply, :ok, %{floors: %{}}}
  end
end
