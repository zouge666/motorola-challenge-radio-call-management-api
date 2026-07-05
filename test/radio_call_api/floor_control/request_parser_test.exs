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

  describe "parse_audit_count/1" do
    test "accepts count between one and one hundred" do
      assert {:ok, 25} = RequestParser.parse_audit_count(%{"count" => "25"})
    end

    test "uses ten as the default count" do
      assert {:ok, 10} = RequestParser.parse_audit_count(%{})
    end

    test "rejects invalid count values" do
      for count <- ["0", "101", "abc", "10abc"] do
        assert {:error, "Invalid request: count must be an integer between 1 and 100"} =
                 RequestParser.parse_audit_count(%{"count" => count})
      end
    end
  end
end
