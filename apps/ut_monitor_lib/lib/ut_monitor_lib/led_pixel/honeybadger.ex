defmodule UtMonitorLib.LedPixel.Honeybadger do

  alias UtMonitorLib.LedPixel

  def pixel_strip(minute_data, hour_data) do
    hour_pixels = aged_pixels_from_hour_list(hour_data |> Enum.slice(14,10))
    minute_pixels = aged_pixels_from_minute_list(minute_data)
    List.flatten([hour_pixels, LedPixel.black_pixel(2), minute_pixels])
  end

  @minute_rate_log_base 3
  @hour_rate_log_base 10

  def aged_pixels_from_minute_list(error_counts) do
    aged_pixels_from_list(error_counts, 60, @minute_rate_log_base)
  end

  def aged_pixels_from_hour_list(error_counts) do
    aged_pixels_from_list(error_counts, 10, @hour_rate_log_base)
  end

  defp aged_pixels_from_list(error_counts, num_slices, log_base) do
    #Oldest error_counts come first, so we want to reverse it so that oldest get the biggest ages
    #Then we need to reverse it again, so that the LED for the oldest error_count value is furthest down the strip
    error_counts |>
      Enum.reverse |>
      Enum.with_index |>
      Enum.map(fn({error_count, age}) -> from_error_count(error_count, log_base, num_slices, age) end) |>
      Enum.reverse
  end

  defp from_error_count(error_count, log_base, age_slices, age) do
    log_count = log_error_count(error_count, log_base)
    %LedPixel{
      h: honeybadger_hue(log_count),
      s: 255,
      l: LedPixel.age_to_lightness(age, age_slices),
      effect: honeybadger_effect(log_count)
    }
  end

  defp log_error_count(0, _) do
    0
  end

  defp log_error_count(1, _) do
    0.1 #ensure that we only have pure green for 0 errors, otherwise log(1) == 0
  end

  defp log_error_count(count, log_base) do
    :math.log(count)/:math.log(log_base)
  end

  defp honeybadger_hue(log_error_count) when log_error_count > 2 do
    0
  end

  defp honeybadger_hue(log_error_count) do
    Kernel.round(120 - (log_error_count * 60))
  end

  defp honeybadger_effect(log_error_count) when log_error_count > 3 do
    "blink"
  end

  defp honeybadger_effect(log_error_count) when log_error_count > 2.5 do
    "breathe"
  end

  defp honeybadger_effect(_) do
    nil
  end

end
