defmodule Nudedisco.RSS.Feed do
  use Ecto.Schema

  alias Nudedisco.RSS

  @type t :: %__MODULE__{
          __meta__: Ecto.Schema.Metadata.t(),
          id: integer(),
          name: String.t(),
          feed_url: String.t(),
          site_url: String.t(),
          slug: String.t(),
          items: [RSS.Item.t()]
        }

  schema "rss_feeds" do
    field(:name, :string)
    field(:feed_url, :string)
    field(:site_url, :string)
    field(:slug, :string)
    has_many(:items, RSS.Item)
  end
end
