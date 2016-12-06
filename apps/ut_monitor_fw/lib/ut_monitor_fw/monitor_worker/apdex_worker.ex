defmodule UtMonitorFw.MonitorWorker.ApdexWorker do
  use GenServer
  require Logger

  alias UtMonitorFw.NotificationEngine

  @polling_interval 60 * 1000 # 1 minutes in milliseconds

  def start_link(app_id, opts \\ []) do
    GenServer.start_link(__MODULE__, app_id, opts)
  end

  def init(app_id) do
    send(self, :wait_for_wifi)
    {:ok, %{app_id: app_id}}
  end

  def handle_info(:wait_for_wifi, state) do
    case Nerves.NetworkInterface.status("wlan0") do
      {:ok, %{is_up: true}} -> Process.send_after(self, :refresh, 1000)
      _ -> Process.send_after(self, :wait_for_wifi, 1000)
    end
    {:noreply, state}
  end

  def handle_info(:refresh, state = %{app_id: app_id}) do
    Task.start_link(fn ->
        case UtMonitorLib.ServiceApis.NewRelic.get_apdex_values(app_id) do
          {:ok, apdex_values} ->
            NotificationEngine.display_data({:apdex_values, apdex_values})
          {:error, _err_msg} ->
            NotificationEngine.display_data({:apdex_error})
        end
      end
    )
    Process.send_after(self, :refresh, @polling_interval)
    {:noreply, state}
  end

end
