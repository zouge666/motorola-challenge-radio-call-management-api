import Config

if config_env() == :prod do
  config :radio_call_api,
    floor_lease_ms: String.to_integer(System.get_env("FLOOR_LEASE_MS", "60000")),
    port: String.to_integer(System.get_env("PORT", "8080"))
end
