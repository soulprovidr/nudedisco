defmodule Nudedisco.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    Supervisor.start_link(
      [
        {Nudedisco.Cache, name: :nudedisco_cache},
        {Nudedisco.RSS, name: :nudedisco_rss},
        {Nudedisco.Web, name: :nudedisco_web},
        {Nudedisco.Spotify, name: :nudedisco_spotify},
        {Nudedisco.Scheduler, name: :nudedisco_scheduler}
      ],
      strategy: :one_for_one
    )
  end
end
