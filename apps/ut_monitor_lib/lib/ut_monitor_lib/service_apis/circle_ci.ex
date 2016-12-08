defmodule UtMonitorLib.ServiceApis.CircleCi do
  @moduledoc false

  def get_all_builds(client \\ UtMonitorLib.ServiceApis.CircleCiClient) do
    make_call(fn -> client.get_all_builds end)
  end

  def get_project_builds(project_spec, client \\ UtMonitorLib.ServiceApis.CircleCiClient) do
    make_call(fn -> client.get_project_builds(project_spec) end)
  end

  defp make_call(call_fn) do
    try do
      case call_fn.() do
        %Tesla.Env{body: build_list, status: 200} ->
          {:ok, Enum.map(build_list, &build_status_tuple(&1))}
        %Tesla.Env{body: body} ->
          {:error, body}
        _ ->
          {:error, "Unknown Error"}
      end
    rescue
      Tesla.Error -> {:error, "Tesla Error"}
    end
  end

  defp build_status_tuple(build_map) do
    repo = Map.get(build_map, "reponame")
    branch = Map.get(build_map, "branch")
    lifecycle = Map.get(build_map, "lifecycle")
    status = Map.get(build_map, "status")
    outcome = Map.get(build_map, "outcome")
    {repo, branch, build_status(lifecycle, status, outcome)}
  end

  defp build_status(lifecycle, status, outcome) do
    case {lifecycle, status, outcome} do
      {_, "failed", _} -> :failed
      {_, "success", _} -> :success
      {_, "running", _} -> :running
      {_, "fixed", _} -> :fixed
      {_, _, "infrastructure_fail"} -> :circleci_failure
      {_, _, "no_tests"} -> :no_tests
      {_, _, "timedout"} -> :timed_out
      {_, _, "canceled"} -> :canceled
      {_, "not_run", _} -> :not_run
      {_, "not_running", _} -> :not_running
      {_, "queued", _} -> :queued
      {_, "scheduled", _} -> :scheduled
      _ -> :unexpected
    end
  end

end
