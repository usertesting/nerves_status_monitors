defmodule UtMonitorFw.Mixfile do
  use Mix.Project

  @target "linkit"

  def project do
    [app: :ut_monitor_fw,
     version: "0.0.1",
     target: @target,
     archives: [nerves_bootstrap: "~> 0.2.1"],
     deps_path: "deps/#{@target}",
     build_path: "_build/#{@target}",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps() ++ system(@target)]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {UtMonitorFw, []},
     applications: [:logger, :nerves_uart, :nerves_interim_wifi, :nerves_ntp, :ut_monitor_lib]]
  end

  def deps do
    [
      {:nerves, "~> 0.4.0"},
      {:nerves_interim_wifi, "~> 0.1"},
      {:nerves_ntp, "~> 0.1"},
      {:ut_monitor_lib, in_umbrella: true},
      {:nerves_uart, "~> 0.1.1"},
      {:credo, "~> 0.4", only: [:dev, :test]},
      {:apex, "~> 1.0.0"}
    ]
  end

  def system(target) do
    [{:"nerves_system_#{target}", "~> 0.10.0"}]
  end

  def aliases do
    ["deps.precompile": ["nerves.precompile", "deps.precompile"],
     "deps.loadpaths":  ["deps.loadpaths", "nerves.loadpaths"]]
  end

end
