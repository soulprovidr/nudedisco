defmodule Nudedisco.Spotify.Auth do
  @moduledoc """
  nudedisco Spotify authorization module.

  The Spotify API requires authorization via OAuth 2.0. The first step is to authorize the application by calling the `authorize/0` function. This function will print the URL to authorize the application.

  After authorizing the application, Spotify will redirect to the `redirect_uri` with a `code` query parameter. This code is used to obtain an `access_token` and `refresh_token` via the `handle_authorization/1` function.
  """

  alias Nudedisco.Cache
  alias Nudedisco.Spotify
  alias Nudedisco.Util

  @access_token_id :spotify_access_token
  @refresh_token_id :spotify_refresh_token

  defp get_refresh_token do
    Cache.get!(@refresh_token_id)
  end

  defp set_refresh_token(refresh_token) do
    Cache.put!(@refresh_token_id, refresh_token)
  end

  defp set_access_token(access_token, expires_in) do
    Cache.put!(@access_token_id, access_token, ttl: expires_in)
  end

  # Refresh the access token.
  # Cache the `refresh_token` and return the new `access_token` (and `expires_in` value).
  @spec refresh_access_token :: {:ok, {String.t(), integer}} | :error
  defp refresh_access_token do
    client_id = Spotify.Constants.client_id()
    client_secret = Spotify.Constants.client_secret()
    refresh_token = get_refresh_token()

    url = "https://accounts.spotify.com/api/token"
    body = {:form, [{"grant_type", "refresh_token"}, {"refresh_token", refresh_token}]}

    headers = [
      {"Accept", "application/json"},
      {"Authorization", "Basic #{Base.encode64("#{client_id}:#{client_secret}")}"}
    ]

    with {:ok, body} <- Util.request(:post, url, body, headers) do
      %{
        "access_token" => access_token,
        "expires_in" => expires_in
      } = decoded_body = Poison.decode!(body)

      if refresh_token = Map.get(decoded_body, "refresh_token") do
        set_refresh_token(refresh_token)
      end

      IO.puts("[Spotify] Successfully refreshed access token.")
      {:ok, {access_token, expires_in}}
    else
      :error ->
        :error
    end
  end

  @spec authorize :: :ok
  def authorize do
    client_id = Spotify.Constants.client_id()
    redirect_uri = Spotify.Constants.redirect_uri()

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

  def is_authorized? do
    case Cache.get!(@refresh_token_id) do
      nil -> false
      _ -> true
    end
  end

  # Get the access token from the cache.
  # If the token is not in the cache, refresh it.
  @spec get_access_token :: {:ok, String.t()} | :error
  def get_access_token do
    result =
      Cache.fetch(
        @access_token_id,
        fn ->
          case refresh_access_token() do
            {:ok, {access_token, expires_in}} ->
              set_access_token(access_token, expires_in)
              {:commit, access_token, ttl: expires_in}

            :error ->
              {:ignore, nil}
          end
        end,
        []
      )

    case result do
      {:ok, access_token} -> {:ok, access_token}
      {:commit, access_token, _ttl} -> {:ok, access_token}
      {:ignore, _} -> :error
    end
  end

  @doc """
  Handle the authorization callback from Spotify.
  Sets the `access_token` in the cache and sets the `refresh_token` in the application environment.
  """
  @spec handle_authorization(String.t()) :: :ok | :error
  def handle_authorization(code) do
    client_id = Spotify.Constants.client_id()
    client_secret = Spotify.Constants.client_secret()
    redirect_uri = Spotify.Constants.redirect_uri()
    url = "https://accounts.spotify.com/api/token"

    body =
      {:form,
       [{"grant_type", "authorization_code"}, {"code", code}, {"redirect_uri", redirect_uri}]}

    headers = [
      {"Accept", "application/json"},
      {"Authorization", "Basic #{Base.encode64("#{client_id}:#{client_secret}")}"}
    ]

    with {:ok, body} <- Util.request(:post, url, body, headers) do
      %{
        "access_token" => access_token,
        "expires_in" => expires_in,
        "refresh_token" => refresh_token
      } = Poison.decode!(body)

      set_access_token(access_token, expires_in)
      set_refresh_token(refresh_token)

      IO.puts("[Spotify] Successfully authorized application.")
      :ok
    else
      :error ->
        :error
    end
  end
end
