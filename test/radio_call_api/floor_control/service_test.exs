defmodule RadioCallApi.FloorControl.ServiceTest do
  use ExUnit.Case, async: false

  alias RadioCallApi.FloorControl.MemoryStore
  alias RadioCallApi.FloorControl.Service

  setup do
    MemoryStore.reset!()
    :ok
  end

  test "obtains an available floor" do
    assert {200, "Floor obtained by user-1 for group group-1"} =
             Service.obtain("group-1", "user-1", 0)
  end

  test "rejects a request from another user" do
    Service.obtain("group-1", "user-1", 0)

    assert {409, "Floor is currently held by user-1 for group group-1"} =
             Service.obtain("group-1", "user-2", 0)
  end

  test "allows the holder to release the floor" do
    Service.obtain("group-1", "user-1", 0)

    assert {200, "Floor released by user-1 for group group-1"} =
             Service.release("group-1", "user-1")
  end

  test "rejects release by a non-holder" do
    Service.obtain("group-1", "user-1", 0)

    assert {403, "User user-2 does not hold the floor for group group-1"} =
             Service.release("group-1", "user-2")
  end
end
