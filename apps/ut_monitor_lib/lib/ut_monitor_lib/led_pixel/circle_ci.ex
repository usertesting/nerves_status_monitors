defmodule UtMonitorLib.LedPixel.CircleCi do

  alias UtMonitorLib.LedPixel

  @steps 18

  def aged_pixels_from_build_list(build_tuples) do
    build_tuples |>
      Enum.with_index |>
      Enum.map(fn({build_tuple, age}) -> from_build_tuple(build_tuple, age) end) |>
      List.flatten |>
      Enum.reverse
  end

  @error_hue 0
  def error_pixels do
    [
      %LedPixel{h: @error_hue, s: 255, effect: :blink, repeat: 2},
      LedPixel.black_pixel
    ]
  end

  defp from_build_tuple({repo, _branch, status}, age) do
    lightness = LedPixel.age_to_lightness(age, @steps)
    effect = build_effect(status)
    hue = build_hue(status)
    [
      %LedPixel{h: project_hue(repo), s: 255, l: lightness, effect: effect},
      %LedPixel{h: hue, s: 255, l: lightness, effect: effect, repeat: 1},
      LedPixel.black_pixel
    ]
  end

  defp project_hue("orders"), do: 240 #blue
  defp project_hue("uploader"), do: 300 #purple

  defp build_hue(status) do
    case status do
      x when x in [:success, :fixed]  -> 120 # green
      x when x in [:failed] -> 0 # red
      x when x in [:timed_out, :circleci_failure] -> 40
      x when x in [:running] -> 60
      x when x in [:canceled] -> 80 #yellow
      _ -> 180
    end
  end

  defp build_effect(status) do
    case status do
      x when x in [:running, :queued, :scheduled, :not_running] -> "breathe"
      x when x in [:timed_out, :circleci_failure] -> "blink"
      _ -> nil
    end
  end


end
