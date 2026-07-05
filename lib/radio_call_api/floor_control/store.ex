defmodule RadioCallApi.FloorControl.Store do
  @moduledoc """
  Behaviour for floor-control backends.
  """

  @type group_id :: String.t()
  @type user_id :: String.t()
  @type priority :: integer()

  @callback claim(group_id(), user_id(), priority(), non_neg_integer()) ::
              {:ok, :granted | :renewed}
              | {:error, {:occupied, user_id()}}

  @callback release(group_id(), user_id()) ::
              :ok | {:error, :not_holder}
end
