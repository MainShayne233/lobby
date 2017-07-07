defmodule Lobby.Mixfile do
  use Mix.Project

  def project do
    [
      app: :lobby,
      version: "0.1.0",
      elixir: "~> 1.4",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
      test_coverage: test_coverage(),
      preferred_cli_env: preferred_cli_env(),
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp test_coverage, do: [tool: ExCoveralls]

  defp preferred_cli_env do
    [
      "coveralls": :test,
      "coveralls.detail": :test,
      "coveralls.post": :test,
      "coveralls.html": :test,
    ]
  end

  defp deps do
    [
      {:mix_test_watch, "~> 0.4.1"},
      {:excoveralls, "~> 0.7.1"},
    ]
  end
end
