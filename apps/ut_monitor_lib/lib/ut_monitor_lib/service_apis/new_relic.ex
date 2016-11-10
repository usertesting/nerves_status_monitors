defmodule UtMonitorLib.ServiceApis.NewRelic do

  def get_apdex_values(client \\ UtMonitorLib.ServiceApis.NewRelicClient) do
    case client.get_apdex_data do
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

  defp calculate_apdex(%{"s" => satisfied, "t" => tolerating, "f" => failing}) do
    (satisfied + tolerating /2)/(satisfied + tolerating + failing)
  end

end
