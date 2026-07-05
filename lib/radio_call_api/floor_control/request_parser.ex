defmodule RadioCallApi.FloorControl.RequestParser do
  @moduledoc """
  Validates and normalizes incoming floor-control request bodies.
  """

  def parse_claim(%{} = params) do
    case required_string(params, "userId") do
      {:ok, user_id} -> {:ok, %{user_id: user_id, priority: 0}}
      {:error, :missing_user_id} -> {:error, "Invalid request: userId is required"}
    end
  end

  defp required_string(params, key) do
    case Map.get(params, key) do
      value when is_binary(value) and value != "" -> {:ok, value}
      _ -> {:error, :missing_user_id}
    end
  end
end
