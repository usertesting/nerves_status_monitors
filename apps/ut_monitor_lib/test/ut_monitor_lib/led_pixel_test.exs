defmodule UtMonitorLib.LedPixelTest do
  @moduledoc false
  use ExUnit.Case, async: true

  alias UtMonitorLib.LedPixel

  describe "LedPixel.from_apdex/2" do
    test "the hue should be 120 (green) when the apdex is between 0.99 and 1.00" do
      %LedPixel{h: hue} = LedPixel.from_apdex(0.99)
      assert hue == 120
      %LedPixel{h: hue} = LedPixel.from_apdex(0.995)
      assert hue == 120
      %LedPixel{h: hue} = LedPixel.from_apdex(1.0)
      assert hue == 120
    end

    test "the hue should be 0 (red) when the apdex is 0.91 and below" do
      %LedPixel{h: hue} = LedPixel.from_apdex(0.91)
      assert hue == 0
      %LedPixel{h: hue} = LedPixel.from_apdex(0.88)
      assert hue == 0
    end

    test "the hue should be 60 (yellow) when the apdex is 0.95" do
      %LedPixel{h: hue} = LedPixel.from_apdex(0.95)
      assert hue == 60
    end

    test "the hue should be between 60 and 120 when the apdex is between 0.95 and 0.99" do
      %LedPixel{h: hue} = LedPixel.from_apdex(0.97)
      assert hue > 60 && hue < 120
    end

    test "the hue should be between 0 and 60 when the apdex is between 0.91 and 0.95" do
      %LedPixel{h: hue} = LedPixel.from_apdex(0.93)
      assert hue > 0 && hue < 60
    end

    test "the effect should be blank when apdex is 0.85 and above" do
      %LedPixel{effect: effect} = LedPixel.from_apdex(0.85)
      assert effect == nil
      %LedPixel{effect: effect} = LedPixel.from_apdex(0.9)
      assert effect == nil
    end

    test "the effect should be \"blink\" when apdex is below 0.85 " do
      %LedPixel{effect: effect} = LedPixel.from_apdex(0.84999999)
      assert effect == "blink"
      %LedPixel{effect: effect} = LedPixel.from_apdex(0.8)
      assert effect == "blink"
    end
  end
end