defmodule RadioCallApi.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children =
      [
        {RadioCallApi.FloorControl.MemoryStore, []}
      ] ++ http_children()

    opts = [strategy: :one_for_one, name: RadioCallApi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp http_children do
    if RadioCallApi.Config.http_server?() do
      [
        {Bandit, plug: RadioCallApi.Http.Router, scheme: :http, port: RadioCallApi.Config.port()}
      ]
    else
      []
    end
  end
end
