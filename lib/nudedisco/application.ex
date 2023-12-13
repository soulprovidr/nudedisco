defmodule Nudedisco.Application do
  @moduledoc false

  use Application

  alias Nudedisco.Repo
  alias Nudedisco.RSS
  alias Nudedisco.Scheduler
  alias Nudedisco.Spotify
  alias Nudedisco.Web

  @impl true
  def start(_type, _args) do
    Supervisor.start_link(
      [
        Repo,
        RSS,
        Spotify,
        Scheduler,
        Web
      ],
      strategy: :one_for_one
    )
  end
end
