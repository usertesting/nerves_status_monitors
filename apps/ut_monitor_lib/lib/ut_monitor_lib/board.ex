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
    uart_opts = [speed: speed, active: false]
    send(self, {:start_uart, port, uart_opts})
    {:ok, %{port: port, conn: nil}}
  end

  def handle_call({:send_command, command_str}, _from, state = %{conn: conn}) do
    send_and_wait_ack(conn, command_str)
    {:reply, :ok, state}
  end

  def handle_call({:batch_commands, commands}, _from, state = %{conn: conn}) do
    Enum.each(commands, &send_and_wait_ack(conn, &1))
    {:reply, :ok, state}
  end

  def handle_info({:start_uart, port, uart_opts}, state) do
    {:ok, serial} = Nerves.UART.start_link
    :ok = Nerves.UART.open(serial, port, uart_opts)
    {:noreply, %{state | conn: serial}}
  end

  defp send_and_wait_ack(conn, command) do
    Logger.info("Sending to Arduino: " <> command)
    Nerves.UART.write(conn, command)
    {:ok, "k"} = Nerves.UART.read(conn)
  end

end
