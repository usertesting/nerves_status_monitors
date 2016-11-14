defmodule UtMonitorFw.MonitorWorker.ApdexWorker do
  use GenServer
  require Logger

  alias UtMonitorFw.NotificationEngine

  @polling_interval 5 * 60 * 1000 # 5 minutes in milliseconds

  def start_link(app_id, opts \\ []) do
    Logger.info "Starting Apdex worker"
    GenServer.start_link(__MODULE__, app_id, opts)
  end

  def init(app_id) do
    Process.send_after(self, :refresh, 30 * 1000)
    {:ok, %{app_id: app_id}}
  end

  def handle_info(:refresh, state = %{app_id: app_id}) do
    Logger.info "Getting Apdex Values."
    case UtMonitorLib.ServiceApis.NewRelic.get_apdex_values(app_id) do
      {:ok, apdex_values} ->
        NotificationEngine.display_data({:apdex_values, apdex_values})
        Logger.info "Got apdex values: " <> inspect(apdex_values)
      {:error, err_msg} ->
        NotificationEngine.display_data({:apdex_error})
        Logger.warn "Error retrieving apdex values: #{err_msg}"
      msg ->
        Logger.error "Unknown message in Apdex worker: " <> inspect(msg)
    end
    Process.send_after(self, :refresh, @polling_interval)
    {:noreply, state}
  end
end
