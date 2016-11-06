defmodule UtMonitorFw.HardwareController.LedController do
  use GenServer

  alias UtMonitorLib.LedPixel

  ## PUBLIC API ##
  def start_link(pin, opts \\ []) do
    GenServer.start_link(__MODULE__, pin, opts)
  end

  def clear_strip(pid) do
   GenServer.call(pid, :clear)
  end

  def push_pixel(pid, pixel = %LedPixel{}) do
    GenServer.call(pid, {:push_pixel, pixel})
  end

  def push_pixels(pid, pixels) do
    GenServer.call(pid, {:push_pixels, pixels})
  end

  ## CALLBACKS ##

  def init(pin) do
    send_command(pin, "reset:erase:")
    {:ok, %{pin: pin}}
  end

  def handle_call(:clear, _from, state = %{pin: pin}) do
    send_command(pin, "erase:")
    {:reply, :ok, state}
  end

  def handle_call({:push_pixel, pixel}, _from, state = %{pin: pin}) do
    send_command(pin, LedPixel.to_command(pixel))
    {:reply, :ok, state}
  end

  def handle_call({:push_pixels, pixels}, _from, state = %{pin: pin}) do
    send_command(pin, Enum.map_join(pixels, ":", fn(pixel) -> LedPixel.to_command(pixel) end))
    {:reply, :ok, state}
  end

  ## HELPER METHODS ##

  defp send_command(_pin, command) do
    UtMonitorFw.Board.send_command("::pause:" <> command <> "continue:")
  end
end
