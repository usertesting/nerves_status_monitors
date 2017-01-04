defmodule Nerves.NetworkInterface do

  def status(_) do
    {:ok, %{is_up: true}}
  end
end
