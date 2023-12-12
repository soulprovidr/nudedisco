defmodule Nudedisco.Repo.Migrations.CreateRssFeeds do
  use Ecto.Migration

  def change do
    create table(:rss_feeds) do
      add :name, :string
      add :feed_url, :string
      add :site_url, :string
      add :slug, :string
    end

    create index(:rss_feeds, [:slug], unique: true)
  end
end
