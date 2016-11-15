defmodule UtMonitorLib.ServiceApis.NewRelic do

  require Logger

  def get_apdex_values(app_id, client \\ UtMonitorLib.ServiceApis.NewRelicClient) do
    case client.get_apdex_data(app_id) do
      :badtime ->
        {:error, "Clock not set."}
      %Tesla.Env{body: body, status: 200} ->
        {:ok, parse_apdex_values(body)}
      %Tesla.Env{body: body} ->
        {:error, body}
      _ ->
        {:error, "Unknown Error"}
    end
  end

  defp parse_apdex_values(body) do
    body
    |> Map.get("metric_data")
    |> Map.get("metrics")
    |> Enum.find(fn(x) -> x["name"] == "Apdex" end)
    |> Map.get("timeslices")
    |> Enum.map(fn(x) -> calculate_apdex(x["values"]) end)
  end

  defp calculate_apdex(%{"s" => 0, "t" => 0, "f" => 0}) do
    1.0
  end

  defp calculate_apdex(%{"s" => satisfied, "t" => tolerating, "f" => failing}) do
    (satisfied + tolerating /2)/(satisfied + tolerating + failing)
  end

end

