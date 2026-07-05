defmodule RadioCallApi.Http.Router do
  @moduledoc """
  Plug router exposing the radio group call management API.
  """

  use Plug.Router

  alias RadioCallApi.Http.FloorController
  alias RadioCallApi.Http.Response

  plug(:match)
  plug(Plug.Parsers, parsers: [:json], pass: ["*/*"], json_decoder: Jason)
  plug(:dispatch)

  post "/groups/:group_id/floor" do
    FloorController.obtain(conn)
  end

  delete "/groups/:group_id/floor/:user_id" do
    FloorController.release(conn)
  end

  match _ do
    Response.json(conn, 404, "Not found")
  end
end
