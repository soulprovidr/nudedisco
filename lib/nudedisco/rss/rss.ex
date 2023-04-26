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
          date: String.t(),
          image: String.t() | nil
        }
end

defmodule Nudedisco.RSS.Config do
  @moduledoc """
  A struct representing an RSS feed configuration.
  """
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
  Fetches a hydrated RSS feed from the cache.

  If the feed is not in the cache, returns a new feed with no items.
  """
  @spec fetch(Nudedisco.RSS.Config.t()) :: Nudedisco.RSS.Feed.t() | nil
  def fetch(%Nudedisco.RSS.Config{} = config) do
    case Nudedisco.Cache.get(config.slug) do
      nil ->
        %{
          name: name,
          site_url: site_url,
          slug: slug
        } = config

        %Nudedisco.RSS.Feed{name: name, site_url: site_url, slug: slug, items: nil}

      feed ->
        feed
    end
  end

  @doc """
  Hydrates and returns an RSS feed from a given RSS feed configuration.
  """
  @spec hydrate(Nudedisco.RSS.Config.t()) :: Nudedisco.RSS.Feed.t()
  def hydrate(%Nudedisco.RSS.Config{} = config) do
    import SweetXml

    %{
      name: name,
      feed_url: feed_url,
      site_url: site_url,
      slug: slug,
      xpath_spec: xpath_spec,
      xpath_subspec: xpath_subspec
    } = config

    feed = %Nudedisco.RSS.Feed{name: name, site_url: site_url, slug: slug, items: nil}

    with {:ok, body} <- Nudedisco.Util.request(:get, feed_url) do
      items =
        xpath(body, xpath_spec, xpath_subspec)
        |> Enum.map(&struct(Nudedisco.RSS.Item, &1))

      %Nudedisco.RSS.Feed{feed | items: items}
    else
      :error ->
        IO.warn("Error reading " <> feed_url <> ".")
        feed
    end
  end
end

defmodule Nudedisco.RSS do
  import SweetXml

  @default_xpath_spec ~x"//item"l
  @default_xpath_subspec [
    title: ~x"./title/text()"s,
    description: ~x"./description/text()"s,
    url: ~x"./link/text()"s,
    date: ~x"./pubDate/text()"s
  ]

  @feed_configs [
    %Nudedisco.RSS.Config{
      name: "Backseat Mafia",
      feed_url: "https://www.backseatmafia.com/category/album-reviews/feed/",
      site_url: "https://www.backseatmafia.com/category/album-reviews/",
      slug: :backseat_mafia,
      xpath_spec: @default_xpath_spec,
      xpath_subspec: @default_xpath_subspec
    },
    %Nudedisco.RSS.Config{
      name: "Bandcamp Daily",
      feed_url: "https://daily.bandcamp.com/feed",
      site_url: "https://daily.bandcamp.com",
      slug: :bandcamp,
      xpath_spec: @default_xpath_spec,
      xpath_subspec: @default_xpath_subspec
    },
    %Nudedisco.RSS.Config{
      name: "Beats Per Minute",
      feed_url: "https://beatsperminute.com/category/reviews/album-reviews/feed/",
      site_url: "https://beatsperminute.com/category/reviews/album-reviews/",
      slug: :beatsperminute,
      xpath_spec: @default_xpath_spec,
      xpath_subspec: @default_xpath_subspec
    },
    %Nudedisco.RSS.Config{
      name: "The Guardian",
      feed_url: "https://www.theguardian.com/music+tone/albumreview/rss",
      site_url: "https://www.theguardian.com/music+tone/albumreview",
      slug: :the_guardian,
      xpath_spec: @default_xpath_spec,
      xpath_subspec: @default_xpath_subspec
    },
    %Nudedisco.RSS.Config{
      name: "The Needledrop",
      feed_url: "https://www.theneedledrop.com/articles?format=rss",
      site_url: "https://www.theneedledrop.com/articles",
      slug: :the_needledrop,
      xpath_spec: @default_xpath_spec,
      xpath_subspec: [
        title: ~x"./title/text()"s,
        description: ~x"./description/text()"s,
        image: ~x"./media:content/@url"s,
        url: ~x"./link/text()"s,
        date: ~x"./pubDate/text()"s
      ]
    },
    %Nudedisco.RSS.Config{
      name: "NME",
      feed_url: "https://www.nme.com/reviews/album/feed",
      site_url: "https://www.nme.com/reviews/album",
      slug: :nme,
      xpath_spec: @default_xpath_spec,
      xpath_subspec: @default_xpath_subspec
    },
    %Nudedisco.RSS.Config{
      name: "NPR",
      feed_url: "https://feeds.npr.org/1104/rss.xml",
      site_url: "https://www.npr.org/sections/music-reviews/",
      slug: :npr,
      xpath_spec: @default_xpath_spec,
      xpath_subspec: @default_xpath_subspec
    },
    %Nudedisco.RSS.Config{
      name: "Pitchfork",
      feed_url: "https://pitchfork.com/feed/feed-album-reviews/rss",
      site_url: "https://pitchfork.com/reviews/albums/",
      slug: :pitchfork,
      xpath_spec: @default_xpath_spec,
      xpath_subspec: [
        title: ~x"./title/text()"s,
        description: ~x"./description/text()"s,
        image: ~x"./media:thumbnail/@url"s,
        url: ~x"./link/text()"s,
        date: ~x"./pubDate/text()"s
      ]
    },
    %Nudedisco.RSS.Config{
      name: "PopMatters",
      feed_url: "https://www.popmatters.com/category/music-reviews/feed",
      site_url: "https://www.popmatters.com/category/music-reviews",
      slug: :popmatters,
      xpath_spec: @default_xpath_spec,
      xpath_subspec: @default_xpath_subspec
    },
    %Nudedisco.RSS.Config{
      name: "The Quietus",
      feed_url: "https://thequietus.com/reviews.atom",
      site_url: "https://thequietus.com",
      slug: :the_quietus,
      xpath_spec: ~x"//entry"l,
      xpath_subspec: [
        title: ~x"./title/text()"s,
        description: ~x"./content/text()"s,
        url: ~x"./link/@href"s,
        date: ~x"./published/text()"s
      ]
    },
    %Nudedisco.RSS.Config{
      name: "Rolling Stone",
      feed_url: "https://www.rollingstone.com/music/music-album-reviews/feed/",
      site_url: "https://www.rollingstone.com/music/music-album-reviews/",
      slug: :rolling_stone,
      xpath_spec: @default_xpath_spec,
      xpath_subspec: @default_xpath_subspec
    }
  ]

  @doc """
  Returns a map of hydrated RSS feeds.
  """
  @spec get_feeds :: %{atom() => Nudedisco.RSS.Feed.t()}
  def get_feeds do
    @feed_configs
    |> Enum.map(&Nudedisco.RSS.Config.fetch/1)
    |> Enum.into(%{}, fn feed -> {feed.slug, feed} end)
  end

  @doc """
  Hydrates the list of RSS feeds defined in @feed_configs and returns a list of tuples containing the feed slug and the hydrated feed.
  """
  @spec hydrate_feeds :: list({atom(), Nudedisco.RSS.Feed.t()})
  def hydrate_feeds do
    @feed_configs
    |> Task.async_stream(
      &Nudedisco.RSS.Config.hydrate/1,
      ordered: false,
      timeout: 30 * 1000
    )
    |> Enum.map(fn {:ok, feed} -> {feed.slug, feed} end)
  end
end
