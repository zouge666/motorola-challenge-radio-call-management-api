defmodule RadioCallApi.FloorControl.RequestParserTest do
  use ExUnit.Case, async: true

  alias RadioCallApi.FloorControl.RequestParser

  describe "parse_claim/1" do
    test "accepts user id and explicit priority" do
      assert {:ok, %{user_id: "user-1", priority: 3}} =
               RequestParser.parse_claim(%{"userId" => "user-1", "priority" => 3})
    end

    test "defaults priority to zero" do
      assert {:ok, %{user_id: "user-1", priority: 0}} =
               RequestParser.parse_claim(%{"userId" => "user-1"})
    end

    test "rejects missing user id" do
      assert {:error, "Invalid request: userId is required"} = RequestParser.parse_claim(%{})
    end

    test "rejects non-integer priority" do
      assert {:error, "Invalid request: priority must be an integer"} =
               RequestParser.parse_claim(%{"userId" => "user-1", "priority" => "high"})
    end
  end
end
