defmodule Mix.Tasks.Rss.Init do
  @moduledoc """
  Populate the database with the RSS feeds specified in `config/runtime.exs`.
  """

  use Mix.Task

  alias Nudedisco.Repo
  alias Nudedisco.RSS

  @requirements ["app.config"]

  def run(_) do
    Ecto.Migrator.with_repo(Repo, fn repo ->
      RSS.feed_configs()
      |> Enum.each(fn config ->
        repo.insert!(
          %RSS.Feed{
            name: config.name,
            feed_url: config.feed_url,
            site_url: config.site_url,
            slug: config.slug
          },
          on_conflict: :replace_all
        )
      end)
    end)
  end
end
