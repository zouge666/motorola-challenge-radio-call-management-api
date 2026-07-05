defmodule RadioCallApi.FloorControl.RequestParserTest do
  use ExUnit.Case, async: true

  alias RadioCallApi.FloorControl.RequestParser

  describe "parse_claim/1" do
    test "accepts user id" do
      assert {:ok, %{user_id: "user-1", priority: 0}} =
               RequestParser.parse_claim(%{"userId" => "user-1"})
    end

    test "rejects missing user id" do
      assert {:error, "Invalid request: userId is required"} = RequestParser.parse_claim(%{})
    end
  end
end
