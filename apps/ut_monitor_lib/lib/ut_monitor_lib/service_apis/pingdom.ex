defmodule UtMonitorLib.ServiceApis.Pingdom do

  #possible statuses: up, down, unconfirmed_down, unknown, paused
  def get_site_status(check_id, client \\ UtMonitorLib.ServiceApis.PingdomClient) do
    case client.get_check_details(check_id) do
      %Tesla.Env{body: %{"check" => %{"id" => ^check_id, "status" => "up"}}, status: 200} ->
        {:ok, :up}
      %Tesla.Env{body: %{"check" => %{"id" => ^check_id, "status" => "down"}}, status: 200} ->
        {:ok, :down}
      %Tesla.Env{body: %{"check" => %{"id" => ^check_id}}, status: 200} ->
        {:ok, :unknown}
      _ ->
        {:error}
    end
  end
end
