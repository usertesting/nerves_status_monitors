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

  defp hardware_worker(%{name: name, pin: pin, type: type}) do
    worker(controller_for_type(type), [pin, [name: name]])
  end

  defp controller_for_type(:led) do
    UtMonitorFw.HardwareController.LedController
  end

  defp controller_for_type(:relay) do
    UtMonitorFw.HardwareController.RelayController
  end

end
