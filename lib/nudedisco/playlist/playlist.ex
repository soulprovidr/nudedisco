defmodule Nudedisco.Playlist do
  @moduledoc """
  nudedisco playlist module.

  Uses the GPT-3 API to extract artist/album metadata from RSS feeds, then
  uses the Spotify API to create a playlist based on this metadata.
  """
  use Task, restart: :transient

  alias Nudedisco.OpenAI
  alias Nudedisco.Playlist
  alias Nudedisco.RSS
  alias Nudedisco.Spotify

  require Logger

  import Ecto.Query

  @type metadata :: %{album: String.t(), artist: String.t()}
  @type opts :: [notify: boolean()]

  @spec create(opts()) :: {:error, String.t()} | :ok
  def create(opts \\ []) do
    case Spotify.is_authorized?() do
      false ->
        {:error, "Not authorized to use the Spotify API."}

      true ->
        Logger.debug("[Playlist] Updating playlist...")

        notify = Keyword.get(opts, :notify, false)
        playlist_id = Playlist.Constants.spotify_playlist_id()

        with rss_items <- get_rss_items(),
             rss_items_metadata <- get_rss_items_metadata(rss_items),
             spotify_album_ids <- get_spotify_album_ids(rss_items_metadata),
             spotify_albums <- get_spotify_albums(spotify_album_ids),
             playlist_items <- Enum.map(spotify_albums, &create_playlist_item/1),
             sorted_playlist_items <- sort_by_artist_popularity(playlist_items),
             track_uris <- Enum.map(sorted_playlist_items, & &1.track_uri),
             {:ok, _} <- Spotify.set_playlist_tracks(playlist_id, track_uris) do
          Logger.info("[Playlist] Successfully updated playlist.")

          if notify do
            Playlist.Notification.send(playlist_items: sorted_playlist_items)
          end

          :ok
        else
          _ ->
            Logger.error("[Playlist] Failed to update playlist.")

            :error
        end
    end
  end

  @spec create_playlist_item(list(String.t())) :: list()
  defp create_playlist_item(spotify_album) do
    random_track =
      Map.get(spotify_album, "tracks")
      |> Map.get("items")
      |> Enum.random()

    spotify_artist = Map.get(spotify_album, "artists", []) |> List.first()

    %Playlist.Item{
      album: Map.get(spotify_album, "name") |> sanitize(),
      artist:
        spotify_artist
        |> Map.get("name")
        |> sanitize(),
      artist_id:
        spotify_artist
        |> Map.get("id"),
      image:
        Map.get(spotify_album, "images", [])
        |> List.first()
        |> Map.get("url"),
      title: Map.get(random_track, "name") |> sanitize(),
      track_uri: Map.get(random_track, "uri")
    }
  end

  @spec get_spotify_albums(list(String.t())) :: list()
  defp get_spotify_albums(album_ids) do
    album_ids
    |> Enum.chunk_every(20)
    |> Task.async_stream(
      fn album_ids ->
        case Spotify.get_albums(album_ids) do
          {:ok, body} -> body
          _ -> nil
        end
      end,
      ordered: false,
      timeout: 30 * 1000,
      on_timeout: :kill_task
    )
    |> Enum.flat_map(fn result ->
      case result do
        {:ok, value} -> Map.get(value, "albums")
        _ -> nil
      end
    end)
  end

  @spec get_spotify_album_ids(list(metadata())) :: list(String.t())
  defp get_spotify_album_ids(metadata_items) do
    get_album_id = fn metadata_item ->
      %{album: album, artist: artist} = metadata_item
      q = "#{artist} #{album}"
      is_album? = fn album -> Map.get(album, "album_type") == "album" end

      with {:ok, body} <- Spotify.search(q, "album") do
        album =
          Map.get(body, "albums")
          |> Map.get("items")
          |> Enum.find(is_album?)

        if is_map(album), do: Map.get(album, "id"), else: nil
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

  @spec get_rss_items() :: list(RSS.Item.t())
  defp get_rss_items() do
    cutoff_date = Timex.now() |> Timex.shift(days: -7)
    RSS.get_items(from(i in RSS.Item, where: i.date > ^cutoff_date))
  end

  @spec get_rss_items_metadata(list(RSS.Item.t())) :: [metadata]
  defp get_rss_items_metadata(feed_items) do
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
    |> Enum.flat_map(fn result ->
      case result do
        {:ok, metadata_items} -> metadata_items
        _ -> []
      end
    end)
    |> Enum.reject(has_nil_metadata_values?)
  end

  defp sanitize(string) do
    string
    |> String.replace("\"", "'")
  end

  defp sort_by_artist_popularity(playlist_items) do
    {:ok, body} = Spotify.get_artists(playlist_items |> Enum.map(& &1.artist_id))

    get_artist_popularity = fn playlist_item ->
      Map.get(body, "artists")
      |> Enum.find(fn artist -> playlist_item.artist_id == Map.get(artist, "id") end)
      |> Map.get("popularity", 0)
    end

    playlist_items
    |> Enum.sort(fn a, b -> get_artist_popularity.(a) > get_artist_popularity.(b) end)
  end
end
