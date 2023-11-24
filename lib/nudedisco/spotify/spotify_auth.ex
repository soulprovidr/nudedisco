defmodule Nudedisco.Spotify.Auth do
  @moduledoc """
  nudedisco Spotify authorization module.

  The Spotify API requires authorization via OAuth 2.0. The first step is to authorize the application by calling the `authorize/0` function. This function will print the URL to authorize the application.

  After authorizing the application, Spotify will redirect to the `redirect_uri` with a `code` query parameter. This code is used to obtain an `access_token` and `refresh_token` via the `handle_authorization/1` function.
  """

  use GenServer

  alias Nudedisco.Spotify
  alias Nudedisco.Util

  @table :spotify_auth

  @access_token_id :access_token
  @refresh_token_id :refresh_token

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    table = :ets.new(@table, [:set, :named_table, :public])
    authorize()
    {:ok, table}
  end

  ### Client API.

  def authorize() do
    GenServer.cast(__MODULE__, :authorize)
  end

  @doc """
  Handle the authorization callback from Spotify.
  Sets the `access_token` in the cache and sets the `refresh_token` in the application environment.
  """
  @spec handle_authorization(String.t()) :: :ok | :error
  def handle_authorization(code) do
    GenServer.cast(__MODULE__, {:handle_authorization, code})
  end

  @spec get_access_token :: String.t() | :error
  def get_access_token do
    GenServer.call(__MODULE__, :get_access_token)
  end

  @spec is_authorized?() :: boolean()
  def is_authorized? do
    GenServer.call(__MODULE__, :is_authorized?)
  end

  ### Helpers.

  defp get_refresh_token do
    case :ets.lookup(@table, @refresh_token_id) do
      [{_, refresh_token}] -> refresh_token
      [] -> nil
    end
  end

  @spec refresh_access_token :: String.t() | nil
  defp refresh_access_token do
    client_id = Spotify.Constants.client_id()
    client_secret = Spotify.Constants.client_secret()
    refresh_token = get_refresh_token()

    if is_nil(refresh_token) do
      IO.puts("[Spotify] No refresh token found.")
      nil
    end

    url = "https://accounts.spotify.com/api/token"
    body = {:form, [{"grant_type", "refresh_token"}, {"refresh_token", refresh_token}]}

    headers = [
      {"Accept", "application/json"},
      {"Authorization", "Basic #{Base.encode64("#{client_id}:#{client_secret}")}"}
    ]

    case Util.request(:post, url, body, headers) do
      {:ok, body} ->
        %{
          "access_token" => access_token,
          "expires_in" => expires_in
        } = decoded_body = Poison.decode!(body)

        set_access_token(access_token, expires_in)

        if refresh_token = Map.get(decoded_body, "refresh_token") do
          set_refresh_token(refresh_token)
        end

        IO.puts("[Spotify] Successfully refreshed access token.")
        access_token

      _ ->
        IO.puts("[Spotify] Could not refresh access token.")
        nil
    end
  end

  defp set_access_token(access_token, expires_in) do
    :ets.insert(@table, {
      @access_token_id,
      access_token,
      :os.system_time(:seconds) + expires_in
    })
  end

  defp set_refresh_token(refresh_token) do
    :ets.insert(@table, {@refresh_token_id, refresh_token})
  end

  ### GenServer callbacks.

  def handle_call(:get_access_token, _from, table) do
    case :ets.lookup(@table, @access_token_id) do
      [] ->
        {:reply, refresh_access_token(), table}

      [{_, access_token, expires_in}] ->
        if expires_in < :os.system_time(:seconds) do
          {:reply, refresh_access_token(), table}
        else
          {:reply, access_token, table}
        end
    end
  end

  def handle_call(:is_authorized?, _from, table) do
    case get_refresh_token() do
      nil -> {:reply, false, table}
      _ -> {:reply, true, table}
    end
  end

  def handle_cast(:authorize, table) do
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
    {:noreply, table}
  end

  def handle_cast({:handle_authorization, code}, table) do
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

    case Util.request(:post, url, body, headers) do
      {:ok, body} ->
        %{
          "access_token" => access_token,
          "expires_in" => expires_in,
          "refresh_token" => refresh_token
        } = Poison.decode!(body)

        set_access_token(access_token, expires_in)
        set_refresh_token(refresh_token)

        IO.puts("[Spotify] Successfully authorized application.")
        {:noreply, table}

      :error ->
        IO.puts("[Spotify] Could not authorize application.")
        {:noreply, table}
    end
  end
end
