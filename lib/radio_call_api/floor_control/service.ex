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
        {409, "Floor is currently held by #{holder} for group #{group_id}"}
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

  defp store do
    MemoryStore
  end
end
