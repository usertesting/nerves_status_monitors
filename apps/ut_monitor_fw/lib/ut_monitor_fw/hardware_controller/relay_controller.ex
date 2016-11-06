defmodule UtMonitorFw.HardwareController.RelayController do
  use GenServer

  ## PUBLIC API ##
  def start_link(pin, opts \\ []) do
    GenServer.start_link(__MODULE__, pin, opts)
  end

  def close_relay(pid) do
   GenServer.call(pid, :close)
  end

  def open_relay(pid) do
    GenServer.call(pid, :open)
  end

  ## CALLBACKS ##

  def init(pin) do
    #TODO: Send the open relay (pin low) command once Jerry adds to Arduino code
    send_command(pin, "TBD")
    {:ok, %{pin: pin, state: :open}}
  end

  def handle_call(:close, _from, %{pin: pin, state: state}) do
    #TODO: Send the close relay (pin high) command once Jerry adds to Arduino code
    if state == :open, do: send_command(pin, "TBD")
    {:reply, :ok, %{pin: pin, state: :closed}}
  end

  def handle_call(:open, _from, %{pin: pin, state: state}) do
    #TODO: Send the open relay (pin low) command once Jerry adds to Arduino code
    if state == :closed, do: send_command(pin, "TBD")
    {:reply, :ok, %{pin: pin, state: :open}}
  end

  ## HELPER METHODS ##

  defp send_command(_pin, command) do
    UtMonitorFw.Board.send_command("::" <> command)
  end
end
