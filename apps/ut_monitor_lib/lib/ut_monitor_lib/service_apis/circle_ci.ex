defmodule UtMonitorLib.ServiceApis.CircleCi do
  @moduledoc false

  def get_all_builds(client \\ UtMonitorLib.ServiceApis.CircleCiClient) do
    case client.get_all_builds do
      %Tesla.Env{body: build_list, status: 200} ->
        {:ok, Enum.map(build_list, &build_status_tuple(&1))}
      _ ->
        {:error}
    end
  end

  def get_project_builds(project_spec, client \\ UtMonitorLib.ServiceApis.CircleCiClient) do
    case client.get_project_builds(project_spec) do
      %Tesla.Env{body: build_list, status: 200} ->
        {:ok, Enum.map(build_list, &build_status_tuple(&1))}
      _ ->
        {:error}
    end
  end

  defp build_status_tuple(build_map) do
    repo = Map.get(build_map, "reponame")
    branch = Map.get(build_map, "branch")
    lifecycle = Map.get(build_map, "lifecycle")
    status = Map.get(build_map, "status")
    outcome = Map.get(build_map, "outcome")
    {:ok, commit_time} = Map.get(build_map, "committer_date") |> Timex.parse("{ISO:Extended:Z}")
    {repo, branch, build_status(lifecycle, status, outcome), commit_time}
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
