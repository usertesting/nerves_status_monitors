defmodule UtMonitorFw.Board do
  use GenServer
  
  ## PUBLIC API ##
  def start_link(port, opts \\ []) do
     GenServer.start_link(__MODULE__, {port, opts}, name: __MODULE__)
  end

  def send_command(command_str) do
    :ok = GenServer.call(__MODULE__, {:send_command, command_str})
  end

  ## GENSERVER CALLBACKS ##
  def init({port, opts}) do
    speed = opts[:speed] || 57600
    uart_opts = [speed: speed, active: true]

    {:ok, serial} = Nerves.UART.start_link
    :ok = Nerves.UART.open(serial, port, uart_opts)

    {:ok, %{conn: serial}}
  end

  def handle_call({:send_command, command_str}, _from, state = %{conn: conn}) do
    Nerves.UART.write(conn, command_str)
    {:reply, :ok, state}
  end
end