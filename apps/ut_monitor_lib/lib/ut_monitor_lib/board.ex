defmodule UtMonitorLib.Board do
  use GenServer
  require Logger

  ## PUBLIC API ##
  def start_link(port, opts \\ []) do
     GenServer.start_link(__MODULE__, {port, opts}, name: __MODULE__)
  end

  def send_command(command_str) do
    :ok = GenServer.call(__MODULE__, {:send_command, command_str})
  end

  def batch_commands(batch) do
    :ok = GenServer.call(__MODULE__, {:batch_commands, batch})
  end

  ## GENSERVER CALLBACKS ##
  def init({port, opts}) do
    speed = opts[:speed] || 57_600
    bench = opts[:bench] || false
    uart_opts = [speed: speed, active: false]
    send(self, {:start_uart, port, uart_opts})
    {:ok, %{port: port, conn: nil, bench: bench}}
  end

  def handle_call({:send_command, command_str}, _from, state = %{conn: conn, bench: bench}) do
    send_and_wait_ack(conn, command_str, bench)
    {:reply, :ok, state}
  end

  def handle_call({:batch_commands, commands}, _from, state = %{conn: conn, bench: bench}) do
    Enum.each(commands, &send_and_wait_ack(conn, &1, bench))
    {:reply, :ok, state}
  end


  ## BENCH MODE ##
  # This is a testing mode that just logs commands to the console
  # Used for testing the system without burning and running on LinkIt
  def handle_info({:start_uart, _port, _uart_opts}, state = %{bench: true}) do
    {:noreply, state}
  end

  ## REAL MODE Actually send commands via UART
  def handle_info({:start_uart, port, uart_opts}, state) do
    {:ok, serial} = Nerves.UART.start_link
    :ok = Nerves.UART.open(serial, port, uart_opts)
    {:noreply, %{state | conn: serial}}
  end

  defp send_and_wait_ack(_, command, true) do
    Logger.info("Sending to Arduino: " <> command)
  end

  defp send_and_wait_ack(conn, command, _) do
    Logger.info("Sending to Arduino: " <> command)
    Nerves.UART.write(conn, command)
    {:ok, "k"} = Nerves.UART.read(conn)
  end

end
