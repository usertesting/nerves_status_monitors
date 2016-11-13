defmodule UtMonitorLib.LedPixel.Apdex do

  alias UtMonitorLib.LedPixel

  @steps 72

  def aged_pixels_from_scorelist(apdex_values) do
    #Oldest apdex comes first, so we want to reverse it so that oldest get the biggest ages
    #Then we need to reverse it again, so that the LED for the oldest apdex value is furthest down the strip
    apdex_values |>
      Enum.reverse |>
      Enum.with_index |>
      Enum.map(fn({apdex, age}) -> from_score(apdex, age) end) |>
      Enum.reverse
  end
  
  def from_score(apdex, age \\ 0) do
    %LedPixel{h: apdex_hue(apdex), s: 255, l: LedPixel.age_to_lightness(age, @steps), effect: apdex_effect(apdex)}
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

  defp apdex_effect(apdex) when apdex < @apdex_blink_threshhold do
    "blink"
  end

  defp apdex_effect(_) do
    nil
  end

end
