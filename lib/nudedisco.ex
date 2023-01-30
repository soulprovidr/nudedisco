defmodule Nudedisco do
  import SweetXml

  @feeds %{
    the_needledrop: &Nudedisco.get_the_needledrop_feed/0,
    nme_reviews: &Nudedisco.get_nme_reviews_feed/0,
    pitchfork_best_albums: &Nudedisco.get_pitchfork_best_albums_feed/0,
    pitchfork_reviews: &Nudedisco.get_pitchfork_reviews_feed/0,
    rolling_stone_reviews: &Nudedisco.get_rolling_stone_reviews_feed/0,
    the_quietus_reviews: &Nudedisco.get_the_quietus_reviews_feed/0,
    the_guardian_reviews: &Nudedisco.get_the_guardian_reviews_feed/0
  }

  defp get_xml(url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}

      _ ->
        {:error}
    end
  end

  defp get_feed(name, url, count, xpath_spec, xpath_subspec) do
    case get_xml(url) do
      {:ok, body} ->
        items =
          xpath(body, xpath_spec, xpath_subspec)
          |> Enum.take(count)

        %{name: name, items: items}

      {:error} ->
        IO.warn("Error reading " <> name <> ".")
        nil
    end
  end

  def get_the_needledrop_feed do
    get_feed(
      "The Needledrop",
      "https://www.theneedledrop.com/articles?format=rss",
      4,
      ~x"//item"l,
      title: ~x"./title/text()"s,
      description: ~x"./description/text()"s,
      image: ~x"./media:content/@url"s,
      url: ~x"./link/text()"s,
      date: ~x"./pubDate/text()"s
    )
  end

  def get_nme_reviews_feed do
    get_feed(
      "NME",
      "https://www.nme.com/reviews/album/feed",
      3,
      ~x"//item"l,
      title: ~x"./title/text()"s,
      description: ~x"./description/text()"s,
      url: ~x"./link/text()"s,
      date: ~x"./pubDate/text()"s
    )
  end

  def get_pitchfork_best_albums_feed do
    get_feed(
      "Pitchfork: Best New Albums",
      "https://pitchfork.com/rss/reviews/best/albums/",
      3,
      ~x"//item"l,
      title: ~x"./title/text()"s,
      description: ~x"./description/text()"s,
      url: ~x"./link/text()"s,
      date: ~x"./pubDate/text()"s
    )
  end

  def get_pitchfork_reviews_feed do
    get_feed(
      "Pitchfork: Album Reviews",
      "https://pitchfork.com/feed/feed-album-reviews/rss",
      4,
      ~x"//item"l,
      title: ~x"./title/text()"s,
      description: ~x"./description/text()"s,
      image: ~x"./media:thumbnail/@url"s,
      url: ~x"./link/text()"s,
      date: ~x"./pubDate/text()"s
    )
  end

  def get_rolling_stone_reviews_feed do
    get_feed(
      "Rolling Stone",
      "https://www.rollingstone.com/music/music-album-reviews/feed/",
      4,
      ~x"//item"l,
      title: ~x"./title/text()"s,
      description: ~x"./description/text()"s,
      url: ~x"./link/text()"s,
      date: ~x"./pubDate/text()"s
    )
  end

  def get_the_guardian_reviews_feed do
    get_feed(
      "The Guardian",
      "https://www.theguardian.com/music+tone/albumreview/rss",
      6,
      ~x"//item"l,
      title: ~x"./title/text()"s,
      description: ~x"./description/text()"s,
      # image: ~x"./media:content/@url[position() = 1]"s,
      url: ~x"./link/text()"s,
      date: ~x"./pubDate/text()"s
    )
  end

  def get_the_quietus_reviews_feed do
    get_feed(
      "The Quietus",
      "https://thequietus.com/reviews.atom",
      4,
      ~x"//entry"l,
      title: ~x"./title/text()"s,
      description: ~x"./content/text()"s,
      url: ~x"./link/@href"s,
      date: ~x"./published/text()"s
    )
  end

  @spec get_all_feeds :: any
  def get_all_feeds do
    for {k, v} <- @feeds, into: %{}, do: {k, v.()}
  end
end
