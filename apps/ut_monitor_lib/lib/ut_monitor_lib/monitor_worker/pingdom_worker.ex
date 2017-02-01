defmodule UtMonitorLib.MonitorWorker.PingdomWorker do
  use GenServer
  require Logger

  alias UtMonitorLib.NotificationEngine

  @polling_interval 60 * 1000 # every minute in milliseconds

  def start_link(check_id, opts \\ []) do
    GenServer.start_link(__MODULE__, check_id, opts)
  end

  def init(check_id) do
    send(self(), :wait_for_wifi)
    {:ok, %{check_id: check_id, status: :up}}
  end

  def handle_info(:wait_for_wifi, state) do
    case Nerves.NetworkInterface.status("wlan0") do
      {:ok, %{is_up: true}} -> send(self(), :refresh)
      _ -> Process.send_after(self(), :wait_for_wifi, 1000)
    end
    {:noreply, state}
  end

  def handle_info(:refresh, state = %{check_id: check_id, status: :up}) do
    case UtMonitorLib.ServiceApis.Pingdom.get_site_status(check_id) do
      {:ok, :down} ->
        NotificationEngine.display_data({:pingdom, :site_down, check_id})
      {:error, _err_msg} ->
        NotificationEngine.display_data({:pingdom_error, check_id})
      _ -> true
    end
    Process.send_after(self(), :refresh, @polling_interval)
    {:noreply, %{state | status: :down}}
  end

  def handle_info(:refresh, state = %{check_id: check_id, status: :down}) do
    case UtMonitorLib.ServiceApis.Pingdom.get_site_status(check_id) do
      {:ok, :up} ->
        NotificationEngine.display_data({:pingdom, :site_up, check_id})
      {:error, _err_msg} ->
        NotificationEngine.display_data({:pingdom_error, check_id})
      _ -> true
    end
    Process.send_after(self(), :refresh, @polling_interval)
    {:noreply, %{state | status: :up}}
  end

end
