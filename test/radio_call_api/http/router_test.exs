defmodule RadioCallApi.Http.RouterTest do
  use ExUnit.Case, async: false

  import Plug.Test

  alias RadioCallApi.FloorControl.MemoryStore
  alias RadioCallApi.Http.Router

  setup do
    MemoryStore.reset!()
    :ok
  end

  test "obtains the floor" do
    conn = request(:post, "/groups/alpha/floor", %{userId: "radio-1"})

    assert conn.status == 200
    assert %{"message" => "Floor obtained by radio-1 for group alpha"} = json(conn)
  end

  test "returns conflict when another user holds the floor" do
    request(:post, "/groups/alpha/floor", %{userId: "radio-1"})

    conn = request(:post, "/groups/alpha/floor", %{userId: "radio-2"})

    assert conn.status == 409
    assert %{"message" => "Floor is currently held by radio-1 for group alpha"} = json(conn)
  end

  test "returns the current floor holder" do
    request(:post, "/groups/alpha/floor", %{userId: "radio-1"})

    conn = request(:get, "/groups/alpha/floor")

    assert conn.status == 200
    assert %{"userId" => "radio-1"} = json(conn)
  end

  test "returns no content when the group has no holder" do
    conn = request(:get, "/groups/alpha/floor")

    assert conn.status == 204
    assert conn.resp_body == ""
  end

  test "releases the floor" do
    request(:post, "/groups/alpha/floor", %{userId: "radio-1"})

    conn = request(:delete, "/groups/alpha/floor/radio-1")

    assert conn.status == 200
    assert %{"message" => "Floor released by radio-1 for group alpha"} = json(conn)
  end

  test "invalid request payload returns bad request" do
    conn = request(:post, "/groups/alpha/floor", %{})

    assert conn.status == 400
    assert %{"message" => "Invalid request: userId is required"} = json(conn)
  end

  test "unmatched routes return not found" do
    conn = request(:get, "/missing")

    assert conn.status == 404
    assert %{"message" => "Not found"} = json(conn)
  end

  defp request(method, path, body \\ nil) do
    method
    |> conn(path, encode_body(body))
    |> maybe_put_json_header(body)
    |> Router.call([])
  end

  defp encode_body(nil), do: nil
  defp encode_body(body), do: Jason.encode!(body)

  defp maybe_put_json_header(conn, nil), do: conn

  defp maybe_put_json_header(conn, _body) do
    Plug.Conn.put_req_header(conn, "content-type", "application/json")
  end

  defp json(conn), do: Jason.decode!(conn.resp_body)
end
