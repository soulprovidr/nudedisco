defmodule Nudedisco.Playlist do
  @moduledoc """
  nudedisco playlist module.

  Uses the GPT-3 API to extract artist/album metadata from RSS feeds, then
  uses the Spotify API to create a playlist based on this metadata.
  """

  alias Nudedisco.OpenAI
  alias Nudedisco.Playlist
  alias Nudedisco.RSS
  alias Nudedisco.Spotify

  @type metadata :: %{album: String.t(), artist: String.t()}

  @spec get_albums(list(String.t())) :: list()
  def get_albums(album_ids) do
    get_album = fn album_id ->
      case Spotify.get_album(album_id) do
        {:ok, body} -> body
        _ -> nil
      end
    end

    album_ids
    |> Task.async_stream(
      get_album,
      ordered: false,
      timeout: 30 * 1000,
      on_timeout: :kill_task
    )
    |> Enum.map(fn result ->
      case result do
        {:ok, value} -> value
        _ -> nil
      end
    end)
    |> Enum.reject(&is_nil/1)
  end

  @spec get_album_ids(list(metadata)) :: list(String.t())
  defp get_album_ids(metadata_items) do
    get_album_id = fn metadata_item ->
      %{album: album, artist: artist} = metadata_item
      q = "#{artist} #{album}"
      is_album? = fn album -> album["album_type"] == "album" end

      with {:ok, body} <- Spotify.search(q, "album"),
           album <-
             Enum.find(body["albums"]["items"], is_album?) do
        album["id"]
      else
        _ -> nil
      end
    end

    metadata_items
    |> Task.async_stream(
      get_album_id,
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

  @spec get_feed_items() :: list(RSS.Item.t())
  defp get_feed_items() do
    RSS.get_feeds()
    |> Enum.map(fn {_k, feed} -> Enum.take(feed.items, 5) end)
    |> List.flatten()
  end

  @spec get_metadata(list(RSS.Item.t())) ::
          list(metadata)
  defp get_metadata(feed_items) do
    # Use GPT-3 to extract album names and artists from RSS feed items.
    extract_metadata = fn items ->
      messages = [
        {"system", Playlist.Constants.system_prompt()},
        {"user", Poison.encode!(items)}
      ]

      with {:ok, body} <- OpenAI.chat_completion(messages),
           {:ok, body} <- Poison.decode(body, %{keys: :atoms!}) do
        body
      else
        _ -> []
      end
    end

    has_nil_metadata_values? = fn metadata ->
      is_nil(Map.get(metadata, :album)) || is_nil(Map.get(metadata, :artist))
    end

    feed_items
    |> Enum.chunk_every(5)
    |> Task.async_stream(
      extract_metadata,
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

  defp get_playlist_items() do
    create_playlist_item = fn album ->
      random_track =
        Map.get(album, "tracks")
        |> Map.get("items")
        |> Enum.random()

      %Playlist.Item{
        album: Map.get(album, "name"),
        artist:
          Map.get(album, "artists", [])
          |> List.first()
          |> Map.get("name"),
        image:
          Map.get(album, "images", [])
          |> List.first()
          |> Map.get("url"),
        title: Map.get(random_track, "name"),
        track_uri: Map.get(random_track, "uri")
      }
    end

    get_feed_items()
    |> get_metadata()
    |> get_album_ids()
    |> get_albums()
    |> Enum.map(create_playlist_item)
  end

  @spec sync! :: boolean()
  def sync! do
    playlist_items = get_playlist_items()
    IO.inspect(playlist_items)
    track_uris = Enum.map(playlist_items, & &1.track_uri)

    case Spotify.set_playlist_tracks(Playlist.Constants.playlist_id(), track_uris) do
      {:ok, _} ->
        IO.puts("[Playlist] Successfully created playlist.")
        true

      _ ->
        IO.puts("[Playlist] Could not create playlist.")
        false
    end
  end
end
