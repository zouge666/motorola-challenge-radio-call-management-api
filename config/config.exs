import Config

config :radio_call_api,
  audit_limit: 1_000,
  floor_lease_ms: 60_000,
  http_server?: true,
  port: 8080

if config_env() == :test do
  import_config "test.exs"
end
