defmodule UtMonitorLib.ServiceApis.HoneybadgerClient do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://app.honeybadger.io/v2"
  plug Tesla.Middleware.Headers, %{"Authorization" =>  "Basic " <> Base.encode64(Application.get_env(:ut_monitor_lib, :honeybadger).api_key)}
  plug Tesla.Middleware.JSON

  def get_error_rates(project_id, buckets \\ "hour", env \\ "production") do
    get("projects/" <> project_id <> "/occurrences", query: [
      environment: env,
      period: buckets
    ])
  end

end
