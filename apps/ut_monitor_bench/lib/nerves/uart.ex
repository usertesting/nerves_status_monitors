defmodule Nerves.UART do

  def start_link do
     {:ok, :dummy}
  end

  def open(_, _, _) do
    :ok
  end

  def write(_, _) do
    :ok
  end

  def read(_) do
    {:ok, "k"}
  end
end
