defmodule Nudedisco.Repo.Migrations.CreateRssFeeds do
  use Ecto.Migration

  def change do
    create table(:rss_feeds) do
      add :name, :string
      add :site_url, :string
      add :slug, :string
    end
  end
end
