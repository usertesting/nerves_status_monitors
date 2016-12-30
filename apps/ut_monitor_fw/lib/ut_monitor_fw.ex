defmodule UtMonitorFw do
  use Application
  alias Nerves.InterimWiFi, as: WiFi

  @arduino_tty "ttyS0"
  @arduino_baud 115_200

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    :os.cmd('modprobe mt7603e')
    # Define workers and child supervisors to be supervised
    children = [
      worker(Task, [fn -> network end], restart: :transient),
      worker(UtMonitorLib.Board, [@arduino_tty, %{speed: @arduino_baud}]),
      worker(UtMonitorFw.NotificationEngine, []),
      supervisor(UtMonitorFw.MonitorSupervisor, []),
      supervisor(UtMonitorFw.HardwareSupervisor, [Application.get_env(:ut_monitor_fw, :hardware_spec)])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: UtMonitorFw.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def network do
    wlan_config = Application.get_env(:ut_monitor_fw, :wlan0)
    WiFi.setup "wlan0", wlan_config
  end

end
