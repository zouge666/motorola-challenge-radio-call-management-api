defmodule RadioCallApi.MixProject do
  use Mix.Project

  def project do
    [
      app: :radio_call_api,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {RadioCallApi.Application, []}
    ]
  end

  defp deps do
    [
      {:plug, "~> 1.15"},
      {:bandit, "~> 1.5"},
      {:jason, "~> 1.4"}
    ]
  end
end
