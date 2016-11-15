defmodule UtMonitorFw.HardwareController.LedController do
  use GenServer
  require Logger
  alias UtMonitorLib.LedPixel

  ## PUBLIC API ##
  def start_link(pin, opts \\ []) do
    Logger.info "Start_linking LED Controller on pin #{pin} with name #{opts[:name]}"
    GenServer.start_link(__MODULE__, pin, opts)
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

  def init(pin) do
    Logger.info "Starting LED Controller on pin #{pin}"
    send_command(pin, "reset:erase:")
    {:ok, %{pin: pin}}
  end

  def handle_call(:clear, _from, state = %{pin: pin}) do
    send_command(pin, "erase:")
    {:reply, :ok, state}
  end

  def handle_call({:push_pixels, []}, _from, state) do
    {:reply, :ok, state}
  end

  def handle_call({:push_pixels, pixels}, _from, state = %{pin: pin}) do
    Logger.info("Pushing pixels: #{inspect pixels}")
    send_pixels(pin, pixels)
    {:reply, :ok, state}
  end

  ## HELPER METHODS ##

  defp send_command(_pin, command) do
    UtMonitorFw.Board.send_command("::pause:" <> command <> "continue:")
  end

  defp send_pixels(_pin, pixels) do
    UtMonitorFw.Board.send_command("::pause:")
    pixels |>
      Enum.chunk(5, 5, []) |>
      Enum.each( fn(pix_list) ->
        pix_list |>
          Enum.map_join(&LedPixel.to_command(&1)) |>
          UtMonitorFw.Board.send_command
        end
      )
    UtMonitorFw.Board.send_command("continue:")
  end
end
