defmodule UtMonitorLib.MonitorSupervisor do
  @moduledoc false

  use Supervisor

  alias UtMonitorLib.CircleCiProjectSpec
  @new_relic_orders_app_id Application.get_env(:ut_monitor_lib, :new_relic).app_id
  @honeybadger_project_id Application.get_env(:ut_monitor_lib, :honeybadger).project_id
  @pingdom_check_id   Application.get_env(:ut_monitor_lib, :pingdom).main_page_check

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    children = [
      worker(UtMonitorLib.MonitorWorker.ApdexWorker, [@new_relic_orders_app_id]),
      worker(UtMonitorLib.MonitorWorker.HoneybadgerWorker, [@honeybadger_project_id]),
      worker(UtMonitorLib.MonitorWorker.PingdomWorker, [@pingdom_check_id]),
      worker(UtMonitorLib.MonitorWorker.CircleCiWorker,[[
        %CircleCiProjectSpec{project: "orders", branch: "master", builds: 12},
        %CircleCiProjectSpec{project: "uploader", branch: "master", builds: 6},
      ]])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
