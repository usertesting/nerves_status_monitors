defmodule UtMonitorBench do
  use Application

  @arduino_tty "ttyS0"
  @arduino_baud 115_200

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    # Define workers and child supervisors to be supervised
    children = [
      worker(UtMonitorLib.Board, [@arduino_tty, %{}]),
      worker(UtMonitorLib.NotificationEngine, []),
      supervisor(UtMonitorLib.MonitorSupervisor, []),
      supervisor(UtMonitorLib.HardwareSupervisor, [Application.get_env(:ut_monitor_bench, :hardware_spec)])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: UtMonitorBench.Supervisor]
    Supervisor.start_link(children, opts)
  end

end
