defmodule UtMonitorLib.LedPixel do
  alias UtMonitorLib.LedPixel

  defstruct h: 0, s: 255, l: 64, effect: nil

  def to_command(%LedPixel{h: h, s: s, l: l, effect: effect}) do
    "#{h},#{s},#{l}:hslcolor:" <> effect_str(effect)
  end

  def from_apdex(apdex, age \\ 0) do
    %LedPixel{h: apdex_hue(apdex), s: 255, l: age_to_lightness(age), effect: apdex_effect(apdex)}
  end

  defp effect_str(nil) do
    ""
  end

  defp effect_str(effect) do
    "#{effect}:"
  end

  @max_brightness 64
  @min_brightness 28
  @steps 72
  defp age_to_lightness(age) do
    #progressively decrease brightness as get older
    #map linearly from 64 (about 25% brightness) down to 28 (about 11%) at age 71
    Kernel.round(@max_brightness - age * (@max_brightness-@min_brightness) / @steps)
  end

  defp apdex_hue(_apdex) do
    0
  end

  defp apdex_effect(_apdex) do
    nil
  end
end
