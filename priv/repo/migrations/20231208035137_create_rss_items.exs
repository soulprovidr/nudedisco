defmodule Nudedisco.Repo.Migrations.CreateRssItems do
  use Ecto.Migration

  def change do
    create table(:rss_items) do
      add :title, :string
      add :description, :string
      add :url, :string
      add :date, :utc_datetime
      add :image_url, :string
      add :feed_id, references(:rss_feeds, on_delete: :delete_all)
    end
  end
end
