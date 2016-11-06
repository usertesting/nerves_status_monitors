defmodule UtMonitorLib.ServiceApis.NewRelicClient do
  use Tesla
  
  @apdex_timeslice 5 * 60 # five minute slices
  @apdex_numslices 72
  @new_relic_app_id "348677"
  
  plug Tesla.Middleware.BaseUrl, "https://api.newrelic.com/v2"
  plug Tesla.Middleware.Headers, %{"X-Api-Key" => Application.get_env(:ut_monitor_lib, :new_relic).api_key}
  plug Tesla.Middleware.JSON
  
  def get_apdex_data(num_slices \\ 72) do
    {:ok, start_time} = (Timex.now |> Timex.shift(seconds: num_slices * @apdex_timeslice * -1) |> Timex.format( "{ISO:Extended}"))
    get("applications/" <> @new_relic_app_id <> "/metrics/data.json", query: [
      names: ["Apdex"],
      raw: false,
      period: @apdex_timeslice,
      from: start_time
    ])
  end
  
end
