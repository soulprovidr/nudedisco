defmodule Nudedisco.Spotify do
  @moduledoc """
  Wrapper around Spotify API functionality.

  See the [Spotify Web API docs](https://developer.spotify.com/documentation/web-api/) for more information.
  """

  use GenServer

  alias Nudedisco.Spotify

  def init(_) do
    Spotify.Auth.authorize()
    {:ok, nil}
  end

  @spec get_album(String.t()) :: :error | {:ok, any}
  def get_album(album_id) do
    Spotify.Util.request(:get, "https://api.spotify.com/v1/albums/#{album_id}")
  end

  @spec get_album_tracks(String.t()) :: :error | {:ok, any}
  def get_album_tracks(album_id) do
    Spotify.Util.request(:get, "https://api.spotify.com/v1/albums/#{album_id}/tracks")
  end

  @doc """
  Search for an item on Spotify.
  See: https://developer.spotify.com/documentation/web-api/reference/search
  """
  @spec search(String.t(), String.t()) :: :error | {:ok, any}
  def search(q, type) do
    Spotify.Util.request(
      :get,
      "https://api.spotify.com/v1/search?" <>
        URI.encode_query(%{
          limit: 1,
          q: q,
          type: type
        })
    )
  end

  @doc """
  Update the items in a playlist.
  See: https://developer.spotify.com/documentation/web-api/reference/reorder-or-replace-playlists-tracks
  """
  @spec set_playlist_tracks(String.t(), [String.t()]) :: :error | {:ok, any}
  def set_playlist_tracks(playlist_id, track_uris) do
    url = "https://api.spotify.com/v1/playlists/#{playlist_id}/tracks"
    body = Poison.encode!(%{"uris" => track_uris})

    with {:ok, body} <- Spotify.Util.request(:put, url, body) do
      {:ok, body}
    else
      :error -> :error
    end
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end
end
