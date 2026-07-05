defmodule RadioCallApi.Http.Response do
  @moduledoc """
  Helpers for consistent HTTP responses.
  """

  alias Plug.Conn

  def json(conn, {status, message}) when is_binary(message) do
    json(conn, status, %{"message" => message})
  end

  def json(conn, status, message) when is_binary(message) do
    json(conn, status, %{"message" => message})
  end

  def json(conn, status, payload) do
    conn
    |> Conn.put_resp_content_type("application/json")
    |> Conn.send_resp(status, Jason.encode!(payload))
  end
end
