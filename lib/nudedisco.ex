defmodule Nudedisco do
  import SweetXml

  @default_xpath_spec ~x"//item"l
  @default_xpath_subspec [
    title: ~x"./title/text()"s,
    description: ~x"./description/text()"s,
    url: ~x"./link/text()"s,
    date: ~x"./pubDate/text()"s
  ]

  @feeds %{
    backseat_mafia: %{
      name: "Backseat Mafia",
      feed_url: "https://www.backseatmafia.com/category/album-reviews/feed/",
      site_url: "https://www.backseatmafia.com/category/album-reviews/",
      items_count: 6,
      xpath_spec: @default_xpath_spec,
      xpath_subspec: @default_xpath_subspec
    },
    beatsperminute: %{
      name: "Beats Per Minute",
      feed_url: "https://beatsperminute.com/category/reviews/album-reviews/feed/",
      site_url: "https://beatsperminute.com/category/reviews/album-reviews/",
      items_count: 6,
      xpath_spec: @default_xpath_spec,
      xpath_subspec: @default_xpath_subspec
    },
    the_classic_review: %{
      name: "The Classic Review",
      feed_url: "https://theclassicreview.com/category/album-reviews/feed/",
      site_url: "https://theclassicreview.com/category/album-reviews/",
      items_count: 6,
      xpath_spec: @default_xpath_spec,
      xpath_subspec: @default_xpath_subspec
    },
    the_guardian: %{
      name: "The Guardian",
      feed_url: "https://www.theguardian.com/music+tone/albumreview/rss",
      site_url: "https://www.theguardian.com/music+tone/albumreview",
      items_count: 6,
      xpath_spec: @default_xpath_spec,
      xpath_subspec: @default_xpath_subspec
    },
    london_jazz_news: %{
      name: "London Jazz News",
      feed_url: "https://londonjazznews.com/category/reviews/album-review/feed/",
      site_url: "https://londonjazznews.com/category/album-review",
      items_count: 6,
      xpath_spec: @default_xpath_spec,
      xpath_subspec: @default_xpath_subspec
    },
    louder_than_war: %{
      name: "Louder Than War",
      feed_url: "https://louderthanwar.com/music/reviews/feed/",
      site_url: "https://louderthanwar.com/music/reviews/album-reviews/",
      items_count: 6,
      xpath_spec: @default_xpath_spec,
      xpath_subspec: @default_xpath_subspec
    },
    the_needledrop: %{
      name: "The Needledrop",
      feed_url: "https://www.theneedledrop.com/articles?format=rss",
      site_url: "https://www.theneedledrop.com/articles",
      items_count: 4,
      xpath_spec: @default_xpath_spec,
      xpath_subspec: [
        title: ~x"./title/text()"s,
        description: ~x"./description/text()"s,
        image: ~x"./media:content/@url"s,
        url: ~x"./link/text()"s,
        date: ~x"./pubDate/text()"s
      ]
    },
    nme: %{
      name: "NME",
      feed_url: "https://www.nme.com/reviews/album/feed",
      site_url: "https://www.nme.com/reviews/album",
      items_count: 3,
      xpath_spec: @default_xpath_spec,
      xpath_subspec: @default_xpath_subspec
    },
    # no_depression: %{
    #   name: "No Depression",
    #   feed_url: "https://www.nodepression.com/album-reviews/feed/",
    #   site_url: "https://www.nodepression.com/album-reviews/",
    #   items_count: 6,
    #   xpath_spec: @default_xpath_spec,
    #   xpath_subspec: @default_xpath_subspec
    # },
    npr: %{
      name: "NPR",
      feed_url: "https://feeds.npr.org/1104/rss.xml",
      site_url: "https://www.npr.org/sections/music-reviews/",
      items_count: 6,
      xpath_spec: @default_xpath_spec,
      xpath_subspec: @default_xpath_subspec
    },
    pitchfork: %{
      name: "Pitchfork: Album Reviews",
      feed_url: "https://pitchfork.com/feed/feed-album-reviews/rss",
      site_url: "https://pitchfork.com/feed-album-reviews",
      items_count: 4,
      xpath_spec: @default_xpath_spec,
      xpath_subspec: [
        title: ~x"./title/text()"s,
        description: ~x"./description/text()"s,
        image: ~x"./media:thumbnail/@url"s,
        url: ~x"./link/text()"s,
        date: ~x"./pubDate/text()"s
      ]
    },
    pitchfork_best_albums: %{
      name: "Pitchfork: Best Albums",
      feed_url: "https://pitchfork.com/rss/reviews/best/albums/",
      site_url: "https://pitchfork.com/reviews/best/albums/",
      items_count: 6,
      xpath_spec: @default_xpath_spec,
      xpath_subspec: @default_xpath_subspec
    },
    popmatters: %{
      name: "PopMatters",
      feed_url: "https://www.popmatters.com/category/music-reviews/feed",
      site_url: "https://www.popmatters.com/category/music-reviews",
      items_count: 6,
      xpath_spec: @default_xpath_spec,
      xpath_subspec: @default_xpath_subspec
    },
    the_quietus: %{
      name: "The Quietus",
      feed_url: "https://thequietus.com/reviews.atom",
      site_url: "https://thequietus.com",
      items_count: 6,
      xpath_spec: ~x"//entry"l,
      xpath_subspec: [
        title: ~x"./title/text()"s,
        description: ~x"./content/text()"s,
        url: ~x"./link/@href"s,
        date: ~x"./published/text()"s
      ]
    },
    readdork: %{
      name: "Dork",
      feed_url: "https://readdork.com/albums/feed/",
      site_url: "https://readdork.com/albums/",
      items_count: 4,
      xpath_spec: @default_xpath_spec,
      xpath_subspec: @default_xpath_subspec
    },
    record_collector_mag: %{
      name: "Record Collector Magazine",
      feed_url: "https://recordcollectormag.com/reviews/album/feed",
      site_url: "https://recordcollectormag.com/reviews/album",
      items_count: 6,
      xpath_spec: @default_xpath_spec,
      xpath_subspec: @default_xpath_subspec
    },
    # riff_magazine: %{
    #   name: "RIFF Magazine",
    #   feed_url: "https://riffmagazine.com/category/album-reviews/feed/",
    #   site_url: "https://riffmagazine.com/category/album-reviews/",
    #   items_count: 6,
    #   xpath_spec: @default_xpath_spec,
    #   xpath_subspec: @default_xpath_subspec
    # },
    rolling_stone: %{
      name: "Rolling Stone",
      feed_url: "https://www.rollingstone.com/music/music-album-reviews/feed/",
      site_url: "https://www.rollingstone.com/music/music-album-reviews/",
      items_count: 6,
      xpath_spec: @default_xpath_spec,
      xpath_subspec: @default_xpath_subspec
    },
    uncut: %{
      name: "UNCUT",
      feed_url: "https://www.uncut.co.uk/reviews/feed/",
      site_url: "https://www.uncut.co.uk/reviews/",
      items_count: 3,
      xpath_spec: @default_xpath_spec,
      xpath_subspec: @default_xpath_subspec
    }
  }

  defp get_xml(url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}

      _ ->
        {:error}
    end
  end

  defp get_feed_items(feed_url, xpath_spec, xpath_subspec) do
    case get_xml(feed_url) do
      {:ok, body} ->
        xpath(body, xpath_spec, xpath_subspec)

      {:error} ->
        IO.warn("Error reading " <> feed_url <> ".")
        nil
    end
  end

  def get_feeds do
    for {k, v} <- @feeds, into: %{} do
      feed = %{name: v.name, site_url: v.site_url, items: nil}
      items = get_feed_items(v.feed_url, v.xpath_spec, v.xpath_subspec)

      case items do
        nil -> {k, feed}
        _ -> {k, Map.put(feed, :items, Enum.take(items, v.items_count))}
      end
    end
  end
end
