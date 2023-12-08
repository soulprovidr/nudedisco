defmodule Nudedisco.RSS.Item do
  @moduledoc """
  A struct representing an RSS feed item.
  """
  use Ecto.Schema

  @derive {Poison.Encoder, except: [:date, :image]}

  schema "rss_items" do
    field(:title, :string)
    field(:description, :string)
    field(:url, :string)
    field(:date, :utc_datetime)
    field(:image, :string)
    belongs_to(:feed, Nudedisco.RSS.Feed)
  end
end
