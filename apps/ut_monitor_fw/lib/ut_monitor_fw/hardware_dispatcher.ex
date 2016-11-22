defmodule UtMonitorFw.HardwareDispatcher do
  @moduledoc false
  require Logger
  use GenServer

  alias UtMonitorFw.HardwareController.LedController
  alias UtMonitorFw.HardwareController.RelayController

  def start_link(known_devices) do
    GenServer.start_link(__MODULE__, [known_devices], [name: __MODULE__])
  end

  def push_pixels(strip_id, pixels) do
    GenServer.call(__MODULE__, {:push_pixels, strip_id, pixels})
  end

  def set_relay(relay_id, state) do
    GenServer.call(__MODULE__, {:set_relay, relay_id, state})
  end

  ## GEN SERVER CALLBACKS
  def init([known_device_list]) do
    Logger.info "Starting Hardware Dispatcher with devices: " <> inspect(known_device_list)
    {:ok, %{known_devices: MapSet.new(known_device_list)}}
  end

  def handle_call({:push_pixels, strip_id, pixels}, _from, state = %{known_devices: known_devices}) do
    if MapSet.member?(known_devices, strip_id) do
      LedController.push_pixels(strip_id, pixels)
    end
    {:reply, :ok, state}
  end

  def handle_call({:set_relay, relay_id, :closed}, _from, state = %{known_devices: known_devices}) do
    if MapSet.member?(known_devices, relay_id) do
      RelayController.close_relay(relay_id)
    end
    {:reply, :ok, state}
  end

  def handle_call({:set_relay, relay_id, :open}, _from, state = %{known_devices: known_devices}) do
    if MapSet.member?(known_devices, relay_id) do
      RelayController.open_relay(relay_id)
    end
    {:reply, :ok, state}
  end

end
