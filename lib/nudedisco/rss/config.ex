defmodule Nudedisco.RSS.Config do
  @moduledoc """
  A struct representing an RSS feed configuration.
  """
  import SweetXml

  alias Nudedisco.RSS
  alias Nudedisco.Util

  defstruct name: "", feed_url: "", site_url: "", slug: "", xpath_spec: nil, xpath_subspec: []

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

  defp default_xpath_spec,
    do: ~x"//item"l

  defp default_xpath_subspec,
    do: [
      title: ~x"./title/text()"s,
      description: ~x"./description/text()"s,
      url: ~x"./link/text()"s,
      date: ~x"./pubDate/text()"s |> transform_by(&Timex.parse!(&1, "{RFC1123}"))
    ]

  @doc """
  Create a new RSS feed configuration from the provided attributes.

  Default `xpath_spec` and `xpath_subspec` values are as follows:
  ```
  default_xpath_spec = ~x"//item"l

  default_xpath_subspec = [
    title: ~x"./title/text()"s,
    description: ~x"./description/text()"s,
    url: ~x"./link/text()"s,
    date: ~x"./pubDate/text()"s |> transform_by(&Timex.parse!(&1, "{RFC1123}"))
  ]
  ```
  """
  def new(attrs \\ %{}) do
    xpath_spec = Map.get(attrs, :xpath_spec, default_xpath_spec())
    xpath_subspec = Keyword.merge(default_xpath_subspec(), attrs |> Map.get(:xpath_subspec, []))

    %RSS.Config{
      name: attrs |> Map.get(:name, ""),
      feed_url: attrs |> Map.get(:feed_url, ""),
      site_url: attrs |> Map.get(:site_url, ""),
      slug: attrs |> Map.get(:slug, ""),
      xpath_spec: xpath_spec,
      xpath_subspec: xpath_subspec
    }
  end

  @doc """
  Hydrates and returns an RSS feed from a given RSS feed configuration.
  """
  @spec hydrate(RSS.Config.t()) :: RSS.Feed.t()
  def hydrate(%RSS.Config{} = config) do
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
