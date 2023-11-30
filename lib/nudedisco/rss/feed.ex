defmodule Nudedisco.RSS.Feed do
  @moduledoc """
  A struct representing a hydrated RSS feed.
  """
  defstruct [:name, :site_url, :slug, :items]

  @typedoc """
  Elixir representation of a hydrated RSS feed.
  """
  @type t :: %__MODULE__{
          name: String.t(),
          site_url: String.t(),
          slug: String.t(),
          items: list(Nudedisco.RSS.Item.t()) | nil
        }
end
