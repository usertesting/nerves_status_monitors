defmodule UtMonitorFw.MonitorWorker.HoneybadgerWorker do
  use GenServer
  require Logger

  alias UtMonitorFw.NotificationEngine

  @polling_interval 60 * 1000 # 1 minutes in milliseconds

  def start_link(project_id, opts \\ []) do
    GenServer.start_link(__MODULE__, project_id, opts)
  end

  def init(project_id) do
    send(self, :wait_for_wifi)
    {:ok, %{project_id: project_id}}
  end

  def handle_info(:wait_for_wifi, state) do
    case Nerves.NetworkInterface.status("wlan0") do
      {:ok, %{is_up: true}} -> Process.send_after(self, :refresh, 1000)
      _ -> Process.send_after(self, :wait_for_wifi, 1000)
    end
    {:noreply, state}
  end

  def handle_info(:refresh, state = %{project_id: project_id}) do
    Logger.info "Getting Honeybadger Values."
    #minute_task = Task.async(fn -> UtMonitorLib.ServiceApis.Honeybadger.get_error_rates(project_id, "hour") end)
    #hour_task = Task.async(fn -> UtMonitorLib.ServiceApis.Honeybadger.get_error_rates(project_id, "day") end)
    #minute_results = Task.await(minute_task)
    #hour_results = Task.await(hour_task)
    minute_results = UtMonitorLib.ServiceApis.Honeybadger.get_error_rates(project_id, "hour")
    hour_results = UtMonitorLib.ServiceApis.Honeybadger.get_error_rates(project_id, "day
    ")
    case {minute_results, hour_results} do
      {{:ok, minute_rates}, {:ok, hour_rates}} ->
        NotificationEngine.display_data({:honeybadger_data, minute_rates, hour_rates})
        Logger.info "Got Honeybadger values: " <> inspect({minute_rates, hour_rates})
      {{:error, msg}, {:ok, _}} ->
        NotificationEngine.display_data({:honeybadger_error})
        Logger.warn "Error retrieving Honeybadger rate by minutes: #{msg}"
      {{:ok, _}, {:error, msg}} ->
        NotificationEngine.display_data({:honeybadger_error})
        Logger.warn "Error retrieving Honeybadger rate by hours: #{msg}"
      {{:error, msg1}, {:error, msg2}} ->
        Logger.error "Error retrieving Honeybadger rate " <> inspect({msg1, msg2})
      msg ->
        Logger.error "Unknown message in Honeybadger worker: " <> inspect(msg)
    end
    Process.send_after(self, :refresh, @polling_interval)
    {:noreply, state}
  end
end
