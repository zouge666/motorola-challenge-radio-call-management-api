defmodule RadioCallApi.Http.FloorController do
  @moduledoc """
  HTTP adapter for floor-control endpoints.
  """

  alias RadioCallApi.FloorControl.RequestParser
  alias RadioCallApi.FloorControl.Service
  alias RadioCallApi.Http.Response

  def obtain(conn) do
    group_id = conn.path_params["group_id"]

    case RequestParser.parse_claim(conn.body_params) do
      {:ok, request} ->
        Response.json(conn, Service.obtain(group_id, request.user_id, request.priority))

      {:error, message} ->
        Response.json(conn, 400, message)
    end
  end

  def release(conn) do
    group_id = conn.path_params["group_id"]
    user_id = conn.path_params["user_id"]

    Response.json(conn, Service.release(group_id, user_id))
  end
end
