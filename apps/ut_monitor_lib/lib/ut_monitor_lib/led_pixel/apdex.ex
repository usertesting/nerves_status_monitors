defmodule UtMonitorLib.LedPixel.Apdex do

  alias UtMonitorLib.LedPixel

  def from_score(apdex, age \\ 0) do
    %LedPixel{h: apdex_hue(apdex), s: 255, l: age_to_lightness(age), effect: apdex_effect(apdex)}
  end

  @max_brightness 64
  @min_brightness 28
  @steps 72
  defp age_to_lightness(age) do
    #progressively decrease brightness as get older
    #map linearly from 64 (about 25% brightness) down to 28 (about 11%) at age 71
    Kernel.round(@max_brightness - age * (@max_brightness-@min_brightness) / @steps)
  end

  @low_green_apdex 0.99
  @high_red_apdex 0.91
  @apdex_blink_threshhold 0.85

  defp apdex_hue(apdex) when apdex > @low_green_apdex do
    120
  end

  defp apdex_hue(apdex) when apdex < @high_red_apdex do
    0
  end

  defp apdex_hue(apdex) do
    Kernel.round((120 / (@low_green_apdex - @high_red_apdex)) * (apdex - @high_red_apdex))
  end

  defp apdex_effect(apdex) when apdex >= @apdex_blink_threshhold do
    nil
  end

  defp apdex_effect(apdex) when apdex < @apdex_blink_threshhold do
    "blink"
  end

end
