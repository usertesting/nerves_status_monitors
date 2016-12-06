defmodule UtMonitorLib.ServiceApis.CircleCiClient do
  @moduledoc false
  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://circleci.com/api/v1.1"
  plug Tesla.Middleware.Headers, %{"Accept" => "application/json"}
  plug Tesla.Middleware.JSON

  alias UtMonitorLib.CircleCiProjectSpec

  def get_all_builds do
    get("recent-builds", query: base_query_params)
  end

  def get_project_builds(project_spec) do
    get(CircleCiProjectSpec.to_url(project_spec), query: base_query_params)
  end

  defp base_query_params do
    [
      {:"circle-token", Application.get_env(:ut_monitor_lib, :circle_ci).token},
      offset: 0,
      limit: 18
    ]
  end
end
