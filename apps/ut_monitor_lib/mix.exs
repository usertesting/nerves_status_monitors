defmodule UtMonitorLib.Mixfile do
  use Mix.Project

  def project do
    [app: :ut_monitor_lib,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :timex, :tesla, :inets, :poison]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:tesla, "~> 0.5.0"},
      {:poison, ">= 1.0.0"},
      {:timex, "~> 3.0"},
      {:credo, "~> 0.4", only: [:dev, :test]},
      {:apex, "~>0.6.0"}
    ]
  end
end
