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
  def claim(group_id, user_id, priority, lease_ms) do
    GenServer.call(__MODULE__, {:claim, group_id, user_id, priority, lease_ms})
  end

  @impl Store
  def release(group_id, user_id) do
    GenServer.call(__MODULE__, {:release, group_id, user_id})
  end

  @impl Store
  def current_holder(group_id) do
    GenServer.call(__MODULE__, {:current_holder, group_id})
  end

  def reset! do
    GenServer.call(__MODULE__, :reset)
  end

  @impl true
  def init(state), do: {:ok, state}

  @impl true
  def handle_call({:claim, group_id, user_id, priority, lease_ms}, _from, state) do
    state = release_if_expired(state, group_id)
    now = DateTime.utc_now()
    expires_at = DateTime.add(now, lease_ms, :millisecond)

    case Map.get(state.floors, group_id) do
      nil ->
        floor = new_floor(user_id, priority, expires_at, make_ref())
        state = put_floor(state, group_id, floor, lease_ms)
        {:reply, {:ok, :granted}, state}

      %{user_id: ^user_id} = current_floor ->
        Process.cancel_timer(current_floor.timer_ref)

        floor = new_floor(user_id, priority, expires_at, make_ref())
        state = put_floor(state, group_id, floor, lease_ms)
        {:reply, {:ok, :renewed}, state}

      %{priority: holder_priority} = holder when priority > holder_priority ->
        Process.cancel_timer(holder.timer_ref)

        floor = new_floor(user_id, priority, expires_at, make_ref())
        state = put_floor(state, group_id, floor, lease_ms)
        {:reply, {:ok, {:preempted, public_holder(holder)}}, state}

      holder ->
        {:reply, {:error, {:occupied, public_holder(holder)}}, state}
    end
  end

  @impl true
  def handle_call({:release, group_id, user_id}, _from, state) do
    state = release_if_expired(state, group_id)

    case Map.get(state.floors, group_id) do
      %{user_id: ^user_id} = floor ->
        Process.cancel_timer(floor.timer_ref)

        state = update_in(state.floors, &Map.delete(&1, group_id))
        {:reply, :ok, state}

      _ ->
        {:reply, {:error, :not_holder}, state}
    end
  end

  @impl true
  def handle_call({:current_holder, group_id}, _from, state) do
    state = release_if_expired(state, group_id)
    holder = state.floors |> Map.get(group_id) |> public_holder()

    {:reply, {:ok, holder}, state}
  end

  @impl true
  def handle_call(:reset, _from, state) do
    Enum.each(state.floors, fn {_group_id, floor} ->
      Process.cancel_timer(floor.timer_ref)
    end)

    {:reply, :ok, %{floors: %{}}}
  end

  @impl true
  def handle_info({:lease_expired, group_id, token}, state) do
    case Map.get(state.floors, group_id) do
      %{timer_token: ^token} ->
        state = update_in(state.floors, &Map.delete(&1, group_id))
        {:noreply, state}

      _ ->
        {:noreply, state}
    end
  end

  defp put_floor(state, group_id, floor, lease_ms) do
    timer_ref =
      Process.send_after(self(), {:lease_expired, group_id, floor.timer_token}, lease_ms)

    floor = Map.put(floor, :timer_ref, timer_ref)

    put_in(state, [:floors, group_id], floor)
  end

  defp release_if_expired(state, group_id) do
    case Map.get(state.floors, group_id) do
      %{expires_at: expires_at} = floor ->
        if DateTime.compare(expires_at, DateTime.utc_now()) == :lt do
          Process.cancel_timer(floor.timer_ref)
          update_in(state.floors, &Map.delete(&1, group_id))
        else
          state
        end

      nil ->
        state
    end
  end

  defp new_floor(user_id, priority, expires_at, token) do
    %{
      user_id: user_id,
      priority: priority,
      expires_at: expires_at,
      timer_token: token,
      timer_ref: nil
    }
  end

  defp public_holder(nil), do: nil
  defp public_holder(floor), do: Map.take(floor, [:user_id, :priority, :expires_at])
end
