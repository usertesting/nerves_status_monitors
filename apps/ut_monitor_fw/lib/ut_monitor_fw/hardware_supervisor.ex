defmodule UtMonitorFw.HardwareSupervisor do
  @moduledoc false
  require Logger
  use Supervisor

  def start_link(hardware_config) do
    Supervisor.start_link(__MODULE__, [hardware_config], name: __MODULE__)
  end

  def init([hardware_config]) do
    Logger.info "Starting Hardware Supervisor"

    children = [
      worker(UtMonitorFw.HardwareDispatcher, [Enum.map(hardware_config, &(&1.name))]) |
      Enum.map(hardware_config, &(hardware_worker(&1)))
    ]

    supervise(children, strategy: :one_for_one)
  end

  defp hardware_worker(%{name: name, buffer: buffer, type: :led}) do
    worker(UtMonitorFw.HardwareController.LedController, [buffer, [name: name]], id: name)
  end

  defp hardware_worker(%{name: name, pin: pin, type: :relay}) do
    worker(UtMonitorFw.HardwareController.RelayController, [pin, [name: name]], id: name)
  end

end
