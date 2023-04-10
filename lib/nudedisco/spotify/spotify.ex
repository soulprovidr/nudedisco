defmodule Nudedisco.Spotify do
  @moduledoc """
  Wrapper around Spotify API functionality.

  See the [Spotify Web API docs](https://developer.spotify.com/documentation/web-api/) for more information.

  ## Authorization
  The Spotify API requires authorization via OAuth 2.0. The first step is to authorize the application by calling the `authorize/0` function. This function will print the URL to authorize the application.

  After authorizing the application, Spotify will redirect to the `redirect_uri` with a `code` query parameter. This code is used to obtain an `access_token` and `refresh_token` via the `handle_authorization/1` function.

  ## Caching
  After authorization, the Spotify `access_token` is cached in the `:nudedisco_cache` process and expires after the amount of time specified by the `expires_in` property, which is returned . The `refresh_token` is stored in the application environment. Once the `access_token` expires, it is automatically refreshed using the `refresh_token` and the new `access_token` is cached when the `get_access_token/0` function is called.

  ## API
  The Spotify API is accessed via the `request/3` function. This function takes a method, path, and body and returns the response body as a string. The `access_token` is automatically added to the request headers.
  """

  use Task

  @spec authorize :: :ok
  def authorize do
    client_id = Application.get_env(:nudedisco, :spotify_client_id)
    redirect_uri = Application.get_env(:nudedisco, :spotify_redirect_uri)

    query = %{
      client_id: client_id,
      response_type: "code",
      redirect_uri: redirect_uri,
      scope: "playlist-modify-public playlist-modify-private",
      show_dialog: "true"
    }

    url = "https://accounts.spotify.com/authorize?" <> URI.encode_query(query)

    IO.puts("[Spotify] Authorize at: #{url}")
  end

  @doc """
  Handle the authorization callback from Spotify.
  Sets the `access_token` in the cache and sets the `refresh_token` in the application environment.
  """
  @spec handle_authorization(String.t()) :: :ok | :error
  def handle_authorization(code) do
    client_id = Application.get_env(:nudedisco, :spotify_client_id)
    client_secret = Application.get_env(:nudedisco, :spotify_client_secret)
    redirect_uri = Application.get_env(:nudedisco, :spotify_redirect_uri)

    url = "https://accounts.spotify.com/api/token"

    body =
      {:form,
       [{"grant_type", "authorization_code"}, {"code", code}, {"redirect_uri", redirect_uri}]}

    headers = [
      {"Accept", "application/json"},
      {"Authorization", "Basic #{Base.encode64("#{client_id}:#{client_secret}")}"}
    ]

    with {:ok, body} <- Nudedisco.Util.request(:post, url, body, headers) do
      %{
        "access_token" => access_token,
        "expires_in" => expires_in,
        "refresh_token" => refresh_token
      } = Poison.decode!(body)

      # Set the access token in the cache.
      Nudedisco.Cache.put(:spotify_token, access_token, ttl: expires_in)

      # Set the refresh token in the application environment.
      Application.put_env(:nudedisco, :spotify_refresh_token, refresh_token)
      :ok
    else
      :error ->
        :error
    end
  end

  # Get the access token from the cache.
  # If the token is not in the cache, refresh it.
  @spec get_access_token :: {:ok, String.t()} | :error
  defp get_access_token do
    result =
      Cachex.fetch(:spotify_token, fn ->
        with {:ok, {access_token, expires_in}} <- refresh_access_token() do
          {:commit, access_token, ttl: expires_in}
        else
          :error ->
            {:ignore, nil}
        end
      end)

    with {:commit, access_token, _ttl} <- result do
      {:ok, access_token}
    else
      {:ignore, _} ->
        :error
    end
  end

  # Make an authenticated request to the Spotify API.
  @spec request(atom, String.t(), String.t() | nil, [{String.t(), String.t()}]) ::
          {:ok, any} | :error
  defp request(method, url, body, headers \\ []) do
    with {:ok, access_token} <- get_access_token(),
         {:ok, body} <-
           Nudedisco.Util.request(method, url, body, [
             {"Authorization", "Bearer #{access_token}}"} | headers
           ]) do
      {:ok, body}
    else
      :error ->
        :error
    end
  end

  # Refresh the access token.
  # Set the `refresh_token` in the application environment and return the new `access_token` (and `expires_in` value).
  @spec refresh_access_token :: {:ok, {String.t(), integer}} | :error
  defp refresh_access_token do
    client_id = Application.get_env(:nudedisco, :spotify_client_id)
    client_secret = Application.get_env(:nudedisco, :spotify_client_secret)
    refresh_token = Application.get_env(:nudedisco, :spotify_refresh_token)

    url = "https://accounts.spotify.com/api/token"
    body = {:form, [{"grant_type", "refresh_token"}, {"refresh_token", refresh_token}]}

    headers = [
      {"Accept", "application/json"},
      {"Authorization", "Basic #{Base.encode64("#{client_id}:#{client_secret}")}"}
    ]

    with {:ok, body} <- Nudedisco.Util.request(:post, url, body, headers) do
      %{
        "access_token" => access_token,
        "expires_in" => expires_in
      } = decoded_body = Poison.decode!(body)

      if refresh_token = decoded_body["refresh_token"] do
        # Set the refresh token in the application environment.
        Application.put_env(:nudedisco, :spotify_refresh_token, refresh_token)
      end

      IO.puts("[Spotify] Successfully refreshed access token.")
      {:ok, {access_token, expires_in}}
    else
      :error ->
        :error
    end
  end

  # Update a playlist's items.
  @spec update_playlist_items(any, any) :: :error | {:ok, any}
  def update_playlist_items(playlist_id, items) do
    url = "https://api.spotify.com/v1/playlists/#{playlist_id}/tracks"

    body = Poison.encode!(%{"uris" => items})

    with {:ok, body} <- request(:put, url, body) do
      IO.puts("[Spotify] Successfully updated playlist items.")
      {:ok, body}
    else
      :error ->
        IO.puts("[Spotify] Failed to update playlist items.")
        :error
    end
  end

  @spec start_link(any) :: {:ok, pid}
  def start_link(_) do
    Task.start_link(__MODULE__, :authorize, [])
  end
end
