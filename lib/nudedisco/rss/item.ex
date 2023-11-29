defmodule Nudedisco.RSS.Item do
  @moduledoc """
  A struct representing an RSS feed item.
  """
  @derive {Poison.Encoder, except: [:date, :image]}
  defstruct [:title, :description, :url, :date, :image]

  @typedoc """
  Elixir representation of an RSS feed item.
  """
  @type t :: %__MODULE__{
          title: String.t(),
          description: String.t(),
          url: String.t(),
          date: DateTime.t(),
          image: String.t() | nil
        }
end
