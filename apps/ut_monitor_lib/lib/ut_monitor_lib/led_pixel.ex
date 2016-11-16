defmodule UtMonitorLib.LedPixel do
  alias UtMonitorLib.LedPixel

  defstruct h: 0, s: 255, l: 64, effect: nil

  def to_command(%LedPixel{h: _, s: _, l: 0, effect: _}) do
    "black:"
  end

  def to_command(%LedPixel{h: h, s: s, l: l, effect: effect}) do
    "#{h},#{s},#{l}:hslcolor:" <> effect_str(effect)
  end

  def black_pixel do
    %LedPixel{l: 0}
  end

  defp effect_str(nil) do
    ""
  end

  defp effect_str(effect) do
    "#{effect}:"
  end

  @max_brightness 50
  @min_brightness 14
  def age_to_lightness(age, slices) do
    #progressively decrease brightness as get older
    #map linearly from 50 (about 20% brightness) down to 14 (about 5%) at age 71
    Kernel.round(@max_brightness - age * (@max_brightness-@min_brightness) / slices)
  end

end
