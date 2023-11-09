defmodule Nudedisco.Playlist do
  @moduledoc """
  nudedisco playlist module.

  Uses the GPT-3 API to extract artist/album metadata from RSS feeds, then
  uses the Spotify API to create a playlist based on this metadata.
  """

  @type metadata :: %{album: String.t(), artist: String.t()}

  # Use GPT-3 to extract album names and artists from RSS feed items.
  @spec extract_metadata(list(Nudedisco.RSS.Item.t())) ::
          list(metadata)
  defp extract_metadata(items) do
    messages = [
      {"system", Nudedisco.Playlist.Constants.system_prompt()},
      {"user", Poison.encode!(items)}
    ]

    with {:ok, body} <- Nudedisco.OpenAI.chat_completion(messages),
         {:ok, body} <- Poison.decode(body, %{keys: :atoms!}) do
      body
    else
      _ -> []
    end
  end

  @spec get_album_id(metadata) :: String.t() | nil
  defp get_album_id(metadata_item) do
    %{album: album, artist: artist} = metadata_item
    q = "#{artist} #{album}"

    is_album? = fn album -> album["album_type"] == "album" end

    with {:ok, body} <- Nudedisco.Spotify.search(q, "album"),
         album <-
           Enum.find(body["albums"]["items"], is_album?) do
      album["id"]
    else
      _ -> nil
    end
  end

  @spec get_album_ids(list(metadata)) :: list(String.t())
  defp get_album_ids(metadata_items) do
    metadata_items
    |> Task.async_stream(
      &get_album_id/1,
      ordered: false,
      timeout: 30 * 1000,
      on_timeout: :kill_task
    )
    |> Enum.map(fn result ->
      case result do
        {:ok, id} -> id
        _ -> nil
      end
    end)
    |> Enum.reject(&is_nil/1)
    |> Enum.uniq()
  end

  @spec get_feed_items() :: list(Nudedisco.RSS.Item.t())
  defp get_feed_items() do
    Nudedisco.RSS.get_feeds()
    |> Enum.map(fn {_k, feed} -> Enum.take(feed.items, 5) end)
    |> List.flatten()
  end

  @spec get_metadata_items(list(Nudedisco.RSS.Item.t())) ::
          list(metadata)
  defp get_metadata_items(feed_items) do
    has_nil_metadata_values? = fn metadata ->
      is_nil(Map.get(metadata, :album)) || is_nil(Map.get(metadata, :artist))
    end

    feed_items
    |> Enum.chunk_every(5)
    |> Task.async_stream(
      &extract_metadata/1,
      ordered: false,
      timeout: 30 * 1000,
      on_timeout: :kill_task
    )
    |> Enum.map(fn result ->
      case result do
        {:ok, metadata_items} -> metadata_items
        _ -> []
      end
    end)
    |> List.flatten()
    |> Enum.reject(has_nil_metadata_values?)
  end

  @spec get_random_track_uri(String.t()) :: String.t() | nil
  defp get_random_track_uri(album_id) do
    case Nudedisco.Spotify.get_album_tracks(album_id) do
      {:ok, body} -> Enum.random(body["items"])["uri"]
      _ -> nil
    end
  end

  @spec get_track_uris(list(String.t())) :: list(String.t())
  defp get_track_uris(album_ids) do
    album_ids
    |> Task.async_stream(
      &get_random_track_uri/1,
      ordered: false,
      timeout: 30 * 1000,
      on_timeout: :kill_task
    )
    |> Enum.map(fn result ->
      case result do
        {:ok, uri} -> uri
        _ -> nil
      end
    end)
    |> Enum.reject(&is_nil/1)
  end

  # Adds the provided track URIs to the Spotify playlist, replacing any previous tracks.
  @spec set_playlist_tracks(list(String.t())) :: {:ok, any} | :error
  defp set_playlist_tracks(track_uris) do
    playlist_id = Application.get_env(:nudedisco, :spotify_playlist_id)
    Nudedisco.Spotify.set_playlist_tracks(playlist_id, track_uris)
  end

  @spec update :: {:ok, any} | :error
  def update do
    get_feed_items()
    |> get_metadata_items()
    |> get_album_ids()
    |> get_track_uris()
    |> set_playlist_tracks()
  end
end
