defmodule Nudedisco.Application do
  @moduledoc false

  use Application

  alias Nudedisco.RSS
  alias Nudedisco.Scheduler
  alias Nudedisco.Spotify
  alias Nudedisco.Web

  @impl true
  def start(_type, _args) do
    Supervisor.start_link(
      [
        {RSS, name: :rss},
        {Spotify, name: :spotify},
        {Scheduler, name: :scheduler},
        {Web, name: :web}
      ],
      strategy: :one_for_one
    )
  end
end
