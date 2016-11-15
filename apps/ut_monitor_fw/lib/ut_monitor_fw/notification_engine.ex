defmodule UtMonitorFw.NotificationEngine do
  @moduledoc false
  require Logger
  use GenServer

  alias UtMonitorLib.LedPixel
  alias UtMonitorFw.HardwareDispatcher

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def display_data(message) do
    GenServer.call(__MODULE__, message)
  end

  ## GEN SERVER CALLBACKS
  def init([]) do
    Logger.info("Starting Notification Engine")
    {:ok, []}
  end

  def handle_call({:apdex_error}, _from, state) do
    Logger.info("Notification Engine Received :apdex_error")
    HardwareDispatcher.push_pixels(:apdex_leds, [%LedPixel{h: 240, effect: "breathe"}])
    {:reply, :ok, state}
  end

  def handle_call({:apdex_values, apdex_values}, _from, state) do
    Logger.info("Notification Engine Received :apdex_values " <> inspect(apdex_values))
    HardwareDispatcher.push_pixels(:apdex_leds, LedPixel.Apdex.aged_pixels_from_scorelist(apdex_values))
    {:reply, :ok, state}
  end

  def handle_call({:honeybadger_error}, _from, state) do
    Logger.info("Notification Engine Received :honeybadger_error")
    HardwareDispatcher.push_pixels(:hb_leds, [%LedPixel{h: 240, effect: "breathe"}])
    {:reply, :ok, state}
  end

  def handle_call({:honeybadger_data, minute_data, hour_data}, _from, state) do
    Logger.info("Honeybadger Error Rate Received :honeybadger_data" <> inspect({minute_data, hour_data}))
    HardwareDispatcher.push_pixels(:hb_leds, LedPixel.Honeybadger.pixel_strip(minute_data, hour_data))
    {:reply, :ok, state}
  end

end
