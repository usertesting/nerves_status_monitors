defmodule UtMonitorFw.Board do
  use GenServer
  require Logger

  ## PUBLIC API ##
  def start_link(port, opts \\ []) do
     GenServer.start_link(__MODULE__, {port, opts}, name: __MODULE__)
  end

  def send_command(command_str) do
    :ok = GenServer.call(__MODULE__, {:send_command, command_str})
  end

  ## GENSERVER CALLBACKS ##
  def init({port, opts}) do
    Logger.info "Starting Board Connection"
    speed = opts[:speed] || 57_600
    uart_opts = [speed: speed, active: true]
    send(self, {:start_uart, port, uart_opts})
    {:ok, %{port: port, conn: nil}}
  end

  def handle_call({:send_command, command_str}, _from, state = %{conn: conn}) do
    Nerves.UART.write(conn, command_str)
    {:reply, :ok, state}
  end

  def handle_info({:start_uart, port, uart_opts}, state) do
    {:ok, serial} = Nerves.UART.start_link
    :ok = Nerves.UART.open(serial, port, uart_opts)
    Logger.info "Board Connection Initialized"
    {:noreply, %{state | conn: serial}}
  end

  def handle_info({:nerves_uart, port, data}, state) do
    Logger.info("Received " <> data <> " on port" <> port)
    {:noreply, state}
  end
end
