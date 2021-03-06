defmodule UtMonitorLib.HardwareController.LedController do
  use GenServer
  require Logger
  alias UtMonitorLib.LedPixel
  alias UtMonitorLib.Board

  ## PUBLIC API ##
  def start_link(display_buffer, opts \\ []) do
    Logger.info "Start_linking LED Controller on display_buffer #{display_buffer} with name #{opts[:name]}"
    GenServer.start_link(__MODULE__, display_buffer, opts)
  end

  def clear_strip(pid) do
   GenServer.call(pid, :clear)
  end

  def push_pixels(pid, pixel = %LedPixel{}) do
    push_pixels(pid, [pixel])
  end

  def push_pixels(pid, pixels) when is_list(pixels) do
    GenServer.call(pid, {:push_pixels, pixels})
  end

  ## CALLBACKS ##

  def init(display_buffer) do
    Logger.info "Starting LED Controller on buffer #{display_buffer}"
    str_buf = Integer.to_string(display_buffer)
    send_command(str_buf, "rst:era:")
    {:ok, %{display_buffer: str_buf}}
  end

  def handle_call(:clear, _from, state = %{display_buffer: display_buffer}) do
    send_command(display_buffer, "era:")
    {:reply, :ok, state}
  end

  def handle_call({:push_pixels, []}, _from, state) do
    {:reply, :ok, state}
  end

  def handle_call({:push_pixels, pixels}, _from, state = %{display_buffer: display_buffer}) do
    Logger.info("Pushing pixels: #{inspect pixels}")
    send_pixels(display_buffer, pixels)
    {:reply, :ok, state}
  end

  ## HELPER METHODS ##

  defp send_command(display_buffer, command) do
    Board.send_command(command_prefix(display_buffer) <> command)
  end

  defp send_pixels(display_buffer, pixels) do
    prefix = [command_prefix(display_buffer)]
    pixel_commands = pixels |>
      Enum.chunk(5, 5, []) |>
      Enum.map(fn(pix_list) -> Enum.map_join(pix_list, &LedPixel.to_command(&1)) end)
    Board.batch_commands(prefix ++ pixel_commands)
  end

  defp command_prefix(display_buffer) do
    display_buffer <> ":dis:"
  end
end
