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
             Service.obtain("group-1", "user-1", 1)

    assert {200, %{"userId" => "user-1", "priority" => 1}} = Service.holder("group-1")
  end

  test "rejects a lower priority request from another user" do
    Service.obtain("group-1", "user-1", 5)

    assert {409, "Floor is currently held by user-1 for group group-1 with priority 5"} =
             Service.obtain("group-1", "user-2", 3)
  end

  test "allows higher priority takeover" do
    Service.obtain("group-1", "user-1", 2)

    assert {200, "Floor obtained by user-2 for group group-1"} =
             Service.obtain("group-1", "user-2", 7)

    assert {200, %{"userId" => "user-2", "priority" => 7}} = Service.holder("group-1")
  end

  test "allows the holder to release the floor" do
    Service.obtain("group-1", "user-1", 1)

    assert {200, "Floor released by user-1 for group group-1"} =
             Service.release("group-1", "user-1")

    assert {204, nil} = Service.holder("group-1")
  end

  test "rejects release by a non-holder" do
    Service.obtain("group-1", "user-1", 1)

    assert {403, "User user-2 does not hold the floor for group group-1"} =
             Service.release("group-1", "user-2")
  end

  test "automatically releases the floor after the lease expires" do
    Service.obtain("group-1", "user-1", 1)

    Process.sleep(250)

    assert {200, "Floor obtained by user-2 for group group-1"} =
             Service.obtain("group-1", "user-2", 1)
  end

  test "returns recent audit events" do
    Service.obtain("group-1", "user-1", 1)
    Service.release("group-1", "user-1")

    assert {200, [latest | _events]} = Service.audit(10)
    assert latest["action"] == "release"
    assert latest["groupId"] == "group-1"
    assert latest["userId"] == "user-1"
    assert latest["priority"] == 1
    assert latest["reason"] == "manual"
    assert is_binary(latest["timestamp"])
  end
end
