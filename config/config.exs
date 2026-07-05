import Config

config :radio_call_api,
  floor_lease_ms: 60_000,
  http_server?: true,
  port: 8080

if config_env() == :test do
  import_config "test.exs"
end
