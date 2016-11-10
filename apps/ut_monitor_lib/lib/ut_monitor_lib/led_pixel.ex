defmodule UtMonitorLib.LedPixel do
  alias UtMonitorLib.LedPixel

  defstruct h: 0, s: 255, l: 64, effect: nil

  def to_command(%LedPixel{h: h, s: s, l: l, effect: effect}) do
    "#{h},#{s},#{l}:hslcolor:" <> effect_str(effect)
  end

  defp effect_str(nil) do
    ""
  end

  defp effect_str(effect) do
    "#{effect}:"
  end

end
