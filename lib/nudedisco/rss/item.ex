defmodule Nudedisco.RSS.Item do
  @moduledoc """
  A struct representing an RSS feed item.
  """
  use Ecto.Schema

  alias Nudedisco.RSS

  @type t :: %__MODULE__{
          __meta__: Ecto.Schema.Metadata.t(),
          id: integer(),
          title: String.t(),
          description: String.t(),
          url: String.t(),
          date: DateTime.t(),
          image_url: String.t(),
          feed: RSS.Feed.t()
        }

  @derive {Poison.Encoder, except: [:date, :image]}

  schema "rss_items" do
    field(:title, :string)
    field(:description, :string)
    field(:url, :string)
    field(:date, :utc_datetime)
    field(:image_url, :string)
    belongs_to(:feed, RSS.Feed)
  end
end
