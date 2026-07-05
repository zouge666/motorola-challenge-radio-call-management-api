defmodule RadioCallApi.FloorControl.Service do
  @moduledoc """
  Public floor-control use cases.
  """

  alias RadioCallApi.Config
  alias RadioCallApi.FloorControl.MemoryStore

  def obtain(group_id, user_id, priority) do
    case store().claim(group_id, user_id, priority, Config.floor_lease_ms()) do
      {:ok, _outcome} ->
        {200, "Floor obtained by #{user_id} for group #{group_id}"}

      {:error, {:occupied, holder}} ->
        {409,
         "Floor is currently held by #{holder.user_id} for group #{group_id} with priority #{holder.priority}"}
    end
  end

  def release(group_id, user_id) do
    case store().release(group_id, user_id) do
      :ok ->
        {200, "Floor released by #{user_id} for group #{group_id}"}

      {:error, :not_holder} ->
        {403, "User #{user_id} does not hold the floor for group #{group_id}"}
    end
  end

  def holder(group_id) do
    case store().current_holder(group_id) do
      {:ok, nil} -> {204, nil}
      {:ok, holder} -> {200, %{"userId" => holder.user_id, "priority" => holder.priority}}
    end
  end

  defp store do
    MemoryStore
  end
end
