defmodule UtMonitorLib.HardwareController.RelayController do
  use GenServer

  alias UtMonitorLib.Board

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

  def handle_call(:close, _from, state = %{pin: pin, state: :open}) do
    pin_on(pin)
    {:reply, :ok, %{state | state: :closed}}
  end

  def handle_call(:close, _from, state = %{state: :closed}) do
    {:reply, :ok, state}
  end

  def handle_call(:open, _from, state = %{pin: pin, state: :closed}) do
    pin_off(pin)
    {:reply, :ok, %{state | state: :open}}
  end

  def handle_call(:open, _from, state = %{state: :open}) do
    {:reply, :ok, state}
  end

  ## HELPER METHODS ##

  defp pin_on(pin) do
    Board.send_command("::" <> pin <> ":pinon:")
  end

  defp pin_off(pin) do
    Board.send_command("::" <> pin <> ":pinoff:")
  end

end
