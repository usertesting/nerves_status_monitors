defmodule UtMonitorFw.MonitorSupervisor do
  @moduledoc false

  use Supervisor

  @new_relic_orders_app_id Application.get_env(:ut_monitor_lib, :new_relic).app_id
  @honeybadger_project_id Application.get_env(:ut_monitor_lib, :honeybadger).project_id

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    children = [
      worker(UtMonitorFw.MonitorWorker.ApdexWorker, [@new_relic_orders_app_id])
    #  worker(UtMonitorFw.MonitorWorker.HoneybadgerWorker, [@honeybadger_project_id])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
