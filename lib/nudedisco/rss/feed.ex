defmodule Nudedisco.RSS.Feed do
  use Ecto.Schema

  schema "rss_feeds" do
    field(:name, :string)
    field(:site_url, :string)
    field(:slug, :string)
    has_many(:items, Nudedisco.RSS.Item)
    timestamps()
  end
end
