defmodule Mix.Tasks.Db.PopulateFeeds do
  @moduledoc """
  Populate the database with the RSS feeds specified in the configuration.
  """

  use Mix.Task

  alias Nudedisco.RSS

  @requirements ["app.config"]

  def run(_) do
    repos()
    |> Enum.each(fn repo ->
      {:ok, _, _} =
        Ecto.Migrator.with_repo(repo, fn repo ->
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
    end)

    Mix.shell().info("RSS feeds populated successfully")
  end

  defp repos do
    Application.load(:nudedisco)
    Application.get_env(:nudedisco, :ecto_repos)
  end
end
