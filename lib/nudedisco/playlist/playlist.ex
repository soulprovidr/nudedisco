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

  @type metadata :: %{album: String.t(), artist: String.t()}
  @type opts :: [notify: boolean()]

  @spec start_link(opts()) :: {:ok, pid()}
  def start_link(opts \\ []) do
    Task.start_link(__MODULE__, :create, opts)
  end

  @spec create(opts()) :: {:error, String.t()} | :ok
  def create(opts \\ []) do
    case Spotify.is_authorized?() do
      true ->
        with {:ok, _} <- update_playlist(opts) do
          :ok
        end

      false ->
        {:error, "Not authorized to use the Spotify API."}
    end
  end

  @spec get_albums(list(String.t())) :: list()
  defp get_albums(album_ids) do
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

  @spec get_album_ids(list(metadata())) :: list(String.t())
  defp get_album_ids(metadata_items) do
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

  @spec update_playlist(opts()) :: :error | {:ok, list(Playlist.Item.t())}
  defp update_playlist(opts) do
    Logger.debug("[Playlist] Updating playlist...")

    playlist_id = Playlist.Constants.spotify_playlist_id()
    notify = Keyword.get(opts, :notify, false)

    with playlist_items <- get_playlist_items(),
         track_uris <- Enum.map(playlist_items, & &1.track_uri),
         {:ok, _} <- Spotify.set_playlist_tracks(playlist_id, track_uris) do
      Logger.info("[Playlist] Successfully updated playlist.")

      if notify do
        Playlist.Notification.send(playlist_items: playlist_items)
      end

      {:ok, playlist_items}
    else
      _ ->
        Logger.error("[Playlist] Failed to update playlist.")

        :error
    end
  end
end
