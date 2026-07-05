defmodule RadioCallApi.Config do
  @moduledoc """
  Reads application configuration used by the service.
  """

  @app :radio_call_api

  def floor_lease_ms do
    Application.fetch_env!(@app, :floor_lease_ms)
  end

  def http_server? do
    Application.fetch_env!(@app, :http_server?)
  end

  def port do
    Application.fetch_env!(@app, :port)
  end
end
