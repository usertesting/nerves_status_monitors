defmodule UtMonitorFw.Mixfile do
  use Mix.Project

  @target "linkit"

  def project do
    [app: :ut_monitor_fw,
     version: "0.0.1",
     target: @target,
     archives: [nerves_bootstrap: "~> 0.1.4"],
     deps_path: "deps/#{@target}",
     build_path: "_build/#{@target}",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases,
     deps: deps ++ system(@target)]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {UtMonitorFw, []},
     applications: [:logger, :nerves_uart, :nerves_interim_wifi, :nerves_ntp]]
  end

  def deps do
    [
      {:nerves, "~> 0.3.0"},
      {:nerves_interim_wifi, "~> 0.1"},
      {:nerves_ntp, "~> 0.1"},
      {:ut_monitor_apis, in_umbrella: true},
      {:nerves_uart, "~> 0.1.1"}
    ]
  end

  def system(target) do
    [{:"nerves_system_#{target}", "~> 0.6.2"}]
  end

  def aliases do
    ["deps.precompile": ["nerves.precompile", "deps.precompile"],
     "deps.loadpaths":  ["deps.loadpaths", "nerves.loadpaths"]]
  end

end