defmodule UtMonitorLib.LedPixel do
  alias UtMonitorLib.LedPixel

  defstruct h: 0, s: 255, l: 64, effect: nil, repeat: 0

  def to_command(%LedPixel{h: _, s: _, l: 0, effect: _, repeat: repeat}) do
    "black:" <> repeat_str(repeat)
  end

  def to_command(%LedPixel{h: h, s: s, l: l, effect: effect, repeat: repeat}) do
    "#{h},#{s},#{l}:hslcolor:" <> effect_str(effect) <> repeat_str(repeat)
  end

  def black_pixel(repeat \\ 0) do
    %LedPixel{l: 0, repeat: repeat}
  end
  
  def error_pixel(repeat \\ 0) do
    %LedPixel{h: 240, effect: "breathe", repeat: repeat}
  end
  

  defp effect_str(nil) do
    ""
  end

  defp effect_str(effect) do
    "#{effect}:"
  end

  defp repeat_str(0) do
    ""
  end
  
  defp repeat_str(repeat) do
    "#{repeat}:repeat:"
  end
  
  @max_brightness 50
  @min_brightness 14
  def age_to_lightness(age, slices) do
    #progressively decrease brightness as get older
    #map linearly from 50 (about 20% brightness) down to 14 (about 5%) at age 71
    Kernel.round(@max_brightness - age * (@max_brightness-@min_brightness) / slices)
  end

end
