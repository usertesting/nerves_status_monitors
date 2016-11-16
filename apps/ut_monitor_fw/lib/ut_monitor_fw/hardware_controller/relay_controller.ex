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
    pin_off(Integer.to_string(pin))
    {:ok, %{pin: Integer.to_string(pin), state: :open}}
  end

  def handle_call(:close, _from, %{pin: pin, state: state}) do
    if state == :open, do: pin_on(pin)
    {:reply, :ok, %{pin: pin, state: :closed}}
  end

  def handle_call(:open, _from, %{pin: pin, state: state}) do
    if state == :closed, do: pin_off(pin)
    {:reply, :ok, %{pin: pin, state: :open}}
  end

  ## HELPER METHODS ##

  defp pin_on(pin) do
    send_command(pin <> ":pinon:")
  end

  defp pin_off(pin) do
    send_command(pin <> ":pinoff:")
  end

  defp send_command(command) do
    UtMonitorFw.Board.send_command("::" <> command)
  end
end
