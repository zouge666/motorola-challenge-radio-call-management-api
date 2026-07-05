defmodule RadioCallApi.FloorControl.RequestParser do
  @moduledoc """
  Validates and normalizes incoming floor-control request bodies.
  """

  @default_priority 0

  def parse_claim(%{} = params) do
    with {:ok, user_id} <- required_string(params, "userId"),
         {:ok, priority} <- optional_integer(params, "priority", @default_priority) do
      {:ok, %{user_id: user_id, priority: priority}}
    else
      {:error, :missing_user_id} -> {:error, "Invalid request: userId is required"}
      {:error, :invalid_priority} -> {:error, "Invalid request: priority must be an integer"}
    end
  end

  def parse_audit_count(params) do
    params
    |> Map.get("count", "10")
    |> parse_count()
  end

  defp required_string(params, key) do
    case Map.get(params, key) do
      value when is_binary(value) and value != "" -> {:ok, value}
      _ -> {:error, :missing_user_id}
    end
  end

  defp optional_integer(params, key, default) do
    case Map.get(params, key, default) do
      value when is_integer(value) -> {:ok, value}
      _ -> {:error, :invalid_priority}
    end
  end

  defp parse_count(value) when is_binary(value) do
    case Integer.parse(value) do
      {count, ""} when count >= 1 and count <= 100 ->
        {:ok, count}

      _ ->
        invalid_count()
    end
  end

  defp parse_count(_value), do: invalid_count()

  defp invalid_count do
    {:error, "Invalid request: count must be an integer between 1 and 100"}
  end
end
