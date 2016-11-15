defmodule UtMonitorFw.MonitorWorker.ApdexWorker do
  use GenServer
  require Logger

  alias UtMonitorFw.NotificationEngine

  @polling_interval 60 * 1000 # 5 minutes in milliseconds

  def start_link(app_id, opts \\ []) do
    Logger.info "Starting Apdex worker"
    GenServer.start_link(__MODULE__, app_id, opts)
  end

  def init(app_id) do
    send(self, :wait_for_wifi)
    {:ok, %{app_id: app_id}}
  end

  def handle_info(:wait_for_wifi, state) do
    case Nerves.NetworkInterface.status("wlan0") do
      {:error, :unknown} -> Process.send_after(self, :wait_for_wifi, 1000)
      {:ok, %{is_up: true}} -> Process.send_after(self, :refresh, 1000)
      {:ok, _} -> Process.send_after(self, :wait_for_wifi, 1000)
    end
    {:noreply, state}
  end

  def handle_info(:refresh, state = %{app_id: app_id}) do
    Logger.info "Getting Apdex Values." <> inspect(self)
    case UtMonitorLib.ServiceApis.NewRelic.get_apdex_values(app_id) do
      {:ok, apdex_values} ->
        Logger.info "Got apdex values: " <> inspect(apdex_values)
        NotificationEngine.display_data({:apdex_values, apdex_values})
        Process.send_after(self, :refresh, @polling_interval)
        {:noreply, state}
      {:error, err_msg} ->
        Logger.warn "Error retrieving apdex values: #{err_msg}"
        NotificationEngine.display_data({:apdex_error})
        Process.send_after(self, :refresh, 15 * 1000)
        {:noreply, state}
      msg ->
        Logger.error "Unknown message in Apdex worker: " <> inspect(msg)
        {:stop, "Unknown message in Apdex worker", state}
    end
  end

end
