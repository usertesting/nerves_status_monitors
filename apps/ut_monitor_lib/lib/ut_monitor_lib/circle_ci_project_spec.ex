defmodule UtMonitorLib.CircleCiProjectSpec do
  @moduledoc false

  alias UtMonitorLib.CircleCiProjectSpec
  defstruct vcs: "github", user: "usertesting", project: nil, branch: nil

  def to_url(%CircleCiProjectSpec{vcs: vcs, user: user, project: project, branch: nil}) do
    ["project", vcs, user, project] |> Enum.join("/")
  end

  def to_url(%CircleCiProjectSpec{vcs: vcs, user: user, project: project, branch: branch}) do
    ["project", vcs, user, project, "tree", branch] |> Enum.join("/")
  end

end
