defmodule Nudedisco.Spotify do
  alias Nudedisco.Spotify

  def child_spec(opts \\ []) do
    %{
      id: Spotify,
      start: {Spotify.Auth, :start_link, [opts]},
      type: :worker
    }
  end

  @spec is_authorized?() :: boolean()
  def is_authorized?() do
    Spotify.Auth.is_authorized?()
  end

  @spec get_album(String.t()) :: :error | {:ok, any}
  def get_album(album_id) do
    Spotify.Util.request(:get, "https://api.spotify.com/v1/albums/#{album_id}")
  end

  @spec get_albums([String.t()]) :: :error | {:ok, any}
  def get_albums(album_ids) do
    Spotify.Util.request(
      :get,
      "https://api.spotify.com/v1/albums?" <> URI.encode_query(%{ids: Enum.join(album_ids, ",")})
    )
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

    Spotify.Util.request(:put, url, body)
  end
end
