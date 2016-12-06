defmodule UtMonitorFw.MonitorWorker.CircleCiWorker do
  use GenServer
  require Logger

  alias UtMonitorFw.NotificationEngine

  @polling_interval 60 * 1000 # 1 minutes in milliseconds

  ## PUBLIC FUNCTION ##
  def start_link(project_list, opts \\ []) do
    GenServer.start_link(__MODULE__, project_list, opts)
  end

  ## CALLBACKS  ##

  def init(project_list) do
    send(self, :wait_for_wifi)
    {:ok, %{project_list: project_list}}
  end

  def handle_info(:wait_for_wifi, state) do
    case Nerves.NetworkInterface.status("wlan0") do
      {:ok, %{is_up: true}} -> Process.send_after(self, :refresh, 1000)
      _ -> Process.send_after(self, :wait_for_wifi, 1000)
    end
    {:noreply, state}
  end

  def handle_info(:refresh, state = %{project_list: project_list}) do
    tasks = Enum.map(project_list, &Task.async(fn -> get_project_info(&1) end)
    builds = tasks |> Enum.map(&Task.await(&1, 10000))
    IO.inspect builds 
    if Enum.any?(builds, &(&1 == :error)) do
      NotificationEngine.display_data({:circle_ci_error})
    else
      builds = builds |> List.flatten |> sort_builds |> Enum.take(18)
      NotificationEngine.display_data({:build_data, builds})
    end   
    Process.send_after(self, :refresh, @polling_interval)
    {:noreply, state}
  end

  defp sort_builds(builds) do
    builds |> Enum.sort(&(elem(&1,3) < elem(&2, 3)))
  end

  defp get_project_info(project_spec) do
    case UtMonitorLib.ServiceApis.CircleCi.get_project_builds(project_spec) do
      {:ok, builds} -> builds
      {:error, _err_msg} -> :error
    end
  end
end
