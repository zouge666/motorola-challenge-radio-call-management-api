defmodule RadioCallApi.Http.Router do
  @moduledoc """
  Plug router exposing the radio group call management API.
  """

  use Plug.Router

  alias RadioCallApi.Http.FloorController
  alias RadioCallApi.Http.Response

  plug(:put_cors_headers)

  plug(Plug.Static,
    at: "/",
    from: :radio_call_api,
    only: ["docs.html", "openapi.yaml"]
  )

  plug(:match)
  plug(Plug.Parsers, parsers: [:json], pass: ["*/*"], json_decoder: Jason)
  plug(:fetch_query_params)
  plug(:dispatch)

  get "/docs" do
    conn
    |> Plug.Conn.put_resp_header("location", "/docs.html")
    |> Plug.Conn.send_resp(302, "")
  end

  get "/health" do
    Response.json(conn, 200, %{"status" => "ok"})
  end

  post "/groups/:group_id/floor" do
    FloorController.obtain(conn)
  end

  get "/groups/:group_id/floor" do
    FloorController.holder(conn)
  end

  delete "/groups/:group_id/floor/:user_id" do
    FloorController.release(conn)
  end

  get "/audit/floor" do
    FloorController.audit(conn)
  end

  options _ do
    Response.json(conn, {204, nil})
  end

  match _ do
    Response.json(conn, 404, "Not found")
  end

  defp put_cors_headers(conn, _opts) do
    conn
    |> Plug.Conn.put_resp_header("access-control-allow-origin", "*")
    |> Plug.Conn.put_resp_header("access-control-allow-headers", "content-type, accept")
    |> Plug.Conn.put_resp_header("access-control-allow-methods", "GET, POST, DELETE, OPTIONS")
    |> Plug.Conn.put_resp_header("access-control-max-age", "86400")
  end
end
