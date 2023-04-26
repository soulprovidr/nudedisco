defmodule Nudedisco.Playlist do
  @moduledoc """
  nudedisco playlist module.

  Uses OpenAI's GPT-3 API to generate a playlist based on a list of album names and artists extracted from RSS feed items.
  """

  @type metadata :: %{album: String.t(), artist: String.t()}

  # Use GPT-3 to extract album names and artists from RSS feed items.
  @spec extract_metadata(list(Nudedisco.RSS.Item.t())) ::
          list(metadata)
  defp extract_metadata(items) do
    messages = [
      {"system",
       "Using the data present in an array of JSON objects representing RSS feed items for music album reviews, provide a JSON array containing a list of JSON objects of the following form: [{album: '<album>', artist: '<artist>'}, ...].

       Both the album and artist keys are required, and should not have associated values that represent null or undefined, such as 'N/A'. For any items where either the artist or album cannot be extracted or inferred, omit the corresponding object from the new list. In other words, only include objects where both album and artist are defined.

       The following are examples of bad results:

        - {'album': 'N/A', 'artist': 'N/A'}
        - {'album': 'N/A', 'artist': 'The Beatles'}
        - {'album': 'Abbey Road', 'artist': 'N/A'}
        - {'album': 'Abbey Road'}
        - {'artist': 'The Beatles'}

       When the artist name takes the form '<name> and ...', '<name> & ...', or '<name> (...)', omit everything after '<name>'.

       The following are examples of bad results:

        - {'album': 'Abbey Road', 'artist': 'The Beatles and Friends'}
        - {'album': 'Abbey Road', 'artist': 'The Beatles & Friends'}
        - {'album': 'Abbey Road', 'artist': 'The Beatles & The Other Guys'}
        - {'album': 'Abbey Road', 'artist': 'The Beatles (and Friends)'}

       Convert all special characters, such as 'ì' to their closest English equivalents.

       The following are examples of bad results:

        - [{'album': 'Abbey Road', 'artist': 'The Béatles'}]
        - [{'album': 'Äbbey Road', 'artist': 'The Beatles'}]

       Answer only with a JSON array and do not include any additional characters or text.

       The following is an example of the expected result:

        - [{'album': 'Abbey Road', 'artist': 'The Beatles'}]"},
      {"user", Poison.encode!(items)}
    ]

    with {:ok, body} <- Nudedisco.OpenAI.chat_completion(messages) do
      Poison.decode!(body, %{keys: :atoms!})
    else
      :error ->
        []
    end
  end

  @spec get_album_id(metadata) :: String.t() | nil
  defp get_album_id(metadata_item) do
    %{album: album, artist: artist} = metadata_item
    q = "#{artist} #{album}"

    with {:ok, body} <- Nudedisco.Spotify.search(q, "album") do
      List.first(body["albums"]["items"])["id"]
    else
      _ ->
        nil
    end
  end

  @spec get_album_ids(list(metadata)) :: list(String.t())
  defp get_album_ids(metadata_items) do
    metadata_items
    |> Task.async_stream(
      &get_album_id/1,
      ordered: false,
      timeout: 30 * 1000
    )
    |> Enum.map(fn {:ok, id} -> id end)
    |> Enum.reject(&is_nil/1)
  end

  @spec get_feed_items() :: list(Nudedisco.RSS.Item.t())
  def get_feed_items() do
    Nudedisco.RSS.get_feeds()
    |> Enum.map(fn {_k, feed} -> Enum.take(feed.items, 5) end)
    |> List.flatten()
  end

  @spec get_metadata_items(list(Nudedisco.RSS.Item.t())) ::
          list(metadata)
  defp get_metadata_items(feed_items) do
    feed_items
    |> Enum.chunk_every(5)
    |> Task.async_stream(
      &extract_metadata/1,
      ordered: false,
      timeout: 30 * 1000
    )
    |> Enum.map(fn {:ok, items} -> items end)
    |> List.flatten()
    |> Enum.reject(&has_nil_metadata_values/1)
    |> Enum.uniq_by(fn m ->
      String.downcase(m.artist)
    end)
  end

  @spec get_track_uri(String.t()) :: String.t() | nil
  defp get_track_uri(album_id) do
    with {:ok, body} <- Nudedisco.Spotify.get_album_tracks(album_id) do
      Enum.random(body["items"])["uri"]
    else
      _ ->
        nil
    end
  end

  @spec get_track_uris(list(String.t())) :: list(String.t())
  defp get_track_uris(album_ids) do
    album_ids
    |> Task.async_stream(
      &get_track_uri/1,
      ordered: false,
      timeout: 30 * 1000
    )
    |> Enum.map(fn {:ok, id} -> id end)
    |> Enum.reject(&is_nil/1)
  end

  @spec has_nil_metadata_values(metadata) :: boolean
  defp has_nil_metadata_values(metadata) do
    !Map.has_key?(metadata, :album) || !Map.has_key?(metadata, :artist) ||
      is_nil(metadata.album) || is_nil(metadata.artist)
  end

  # Updates the Spotify playlist with the given track URIs.
  @spec update_playlist_items(list(String.t())) :: {:ok, any} | :error
  defp update_playlist_items(track_uris) do
    playlist_id = Application.get_env(:nudedisco, :spotify_playlist_id)
    Nudedisco.Spotify.update_playlist_items(playlist_id, track_uris)
  end

  @spec update :: :error | {:ok, any}
  def update do
    get_feed_items()
    |> get_metadata_items()
    |> get_album_ids()
    |> get_track_uris()
    |> update_playlist_items()
  end
end
