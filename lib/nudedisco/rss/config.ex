defmodule Nudedisco.RSS.Config do
  @moduledoc """
  A struct representing an RSS feed configuration.
  """

  alias Nudedisco.RSS
  alias Nudedisco.Util

  defstruct [:name, :feed_url, :site_url, :slug, :xpath_spec, :xpath_subspec]

  @typedoc """
  Elixir representation of an RSS feed configuration.
  """
  @type t :: %__MODULE__{
          name: String.t(),
          feed_url: String.t(),
          site_url: String.t(),
          slug: String.t(),
          xpath_spec: %SweetXpath{},
          xpath_subspec: list(%SweetXpath{})
        }

  @doc """
  Hydrates and returns an RSS feed from a given RSS feed configuration.
  """
  @spec hydrate(RSS.Config.t()) :: RSS.Feed.t()
  def hydrate(%RSS.Config{} = config) do
    import SweetXml

    %{
      name: name,
      feed_url: feed_url,
      site_url: site_url,
      slug: slug,
      xpath_spec: xpath_spec,
      xpath_subspec: xpath_subspec
    } = config

    feed = %RSS.Feed{name: name, site_url: site_url, slug: slug, items: nil}

    with {:ok, body} <- Util.request(:get, feed_url) do
      items =
        xpath(body, xpath_spec, xpath_subspec)
        |> Enum.map(&struct(RSS.Item, &1))

      %RSS.Feed{feed | items: items}
    else
      :error ->
        IO.warn("Error reading " <> feed_url <> ".")
        feed
    end
  end
end