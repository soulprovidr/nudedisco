defmodule Nudedisco do
  defmodule Item do
    defstruct [:title, :description, :url, :date]
  end

  defp convert_map_to_content_item(m) when is_map(m) do
    struct(Item, m)
  end

  def get_pitchfork_best_albums do
    case HTTPoison.get("https://pitchfork.com/rss/reviews/best/albums/") do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        import SweetXml
        body
        |> xpath(
          ~x"//item"l,
            title: ~x"./title/text()"s,
            description: ~x"./description/text()"s,
            url: ~x"./link/text()"s,
            date: ~x"./pubDate/text()"s
        )
        |> Enum.map(&convert_map_to_content_item/1)
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect(reason)
        []
    end
  end

  def get_the_guardian_reviews do
    case HTTPoison.get("https://www.theguardian.com/music+tone/albumreview/rss") do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        import SweetXml
        body
        |> xpath(
          ~x"//item"l,
            title: ~x"./title/text()"s,
            description: ~x"./description/text()"s,
            url: ~x"./link/text()"s,
            date: ~x"./pubDate/text()"s
        )
        |> Enum.map(&convert_map_to_content_item/1)
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect(reason)
        []
    end
  end
end
