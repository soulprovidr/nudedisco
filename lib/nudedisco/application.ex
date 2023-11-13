defmodule Nudedisco.Application do
  @moduledoc false

  use Application

  alias Nudedisco.Cache
  alias Nudedisco.RSS
  alias Nudedisco.Scheduler
  alias Nudedisco.Spotify
  alias Nudedisco.Web

  @impl true
  def start(_type, _args) do
    Supervisor.start_link(
      [
        {Cache, name: :nudedisco_cache},
        {RSS, name: :nudedisco_rss},
        {Spotify, name: :nudedisco_spotify},
        {Scheduler, name: :nudedisco_scheduler},
        {Web, name: :nudedisco_web}
      ],
      strategy: :one_for_one
    )
  end
end
