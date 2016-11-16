defmodule UtMonitorLib.ServiceApis.Honeybadger do

  def get_error_rates(project_id, buckets, client \\ UtMonitorLib.ServiceApis.HoneybadgerClient) do
    case client.get_error_rates(project_id, buckets) do
      %Tesla.Env{body: body, status: 200} ->
        {:ok, parse_error_rates(body)}
      %Tesla.Env{body: body} ->
        {:error, body}
      _ ->
        {:error, "Unknown Error"}
    end
  end

  defp parse_error_rates(body) do
    body
    |> Enum.map(&Enum.at(&1, 1))
  end

end
