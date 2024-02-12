defmodule Nudedisco.Spotify.Auth do
  @moduledoc """
  nudedisco Spotify authorization module.

  The Spotify API requires authorization via OAuth 2.0. The first step is to authorize the application by calling the `authorize/0` function. This function will print the URL to authorize the application.

  After authorizing the application, Spotify will redirect to the `redirect_uri` with a `code` query parameter. This code is used to obtain an `access_token` and `refresh_token` via the `handle_authorization/1` function.
  """

  use GenServer

  alias Nudedisco.Listmonk
  alias Nudedisco.Spotify
  alias Nudedisco.Util

  require Logger

  @type state :: %{
          access_token: String.t(),
          expires_at: integer(),
          refresh_token: String.t()
        }

  defp admin_email, do: Application.get_env(:nudedisco, :admin_email)
  defp client_id, do: Application.get_env(:nudedisco, Spotify)[:client_id]
  defp client_secret, do: Application.get_env(:nudedisco, Spotify)[:client_secret]

  defp listmonk_authorization_template_id,
    do: Application.get_env(:nudedisco, Spotify)[:listmonk_authorization_template_id]

  defp redirect_uri, do: Application.get_env(:nudedisco, Spotify)[:redirect_uri]

  defp headers,
    do: [
      {"Accept", "application/json"},
      {"Authorization", "Basic #{Base.encode64("#{client_id()}:#{client_secret()}")}"}
    ]

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def init(_) do
    state = %{
      access_token: nil,
      expires_at: nil,
      refresh_token: nil
    }

    handle_cast(:authorize, state)
    {:ok, state}
  end

  @spec get_access_token :: String.t() | :error
  def get_access_token do
    GenServer.call(__MODULE__, :get_access_token)
  end

  @spec handle_authorization(String.t()) :: :ok
  def handle_authorization(code) do
    GenServer.cast(__MODULE__, {:handle_authorization, code})
  end

  @spec is_authorized?() :: boolean()
  def is_authorized? do
    GenServer.call(__MODULE__, :is_authorized?)
  end

  @spec refresh_access_token(String.t()) :: {:ok, state()} | :error
  defp refresh_access_token(refresh_token) do
    if is_nil(refresh_token) do
      Logger.debug("[Spotify] No refresh token found.")
      :error
    end

    url = "https://accounts.spotify.com/api/token"
    body = {:form, [{"grant_type", "refresh_token"}, {"refresh_token", refresh_token}]}

    case Util.request(:post, url, body, headers()) do
      {:ok, body} ->
        %{
          "access_token" => access_token,
          "expires_in" => expires_in
        } = decoded_body = Poison.decode!(body)

        Logger.debug("[Spotify] Successfully refreshed access token.")

        state = %{
          access_token: access_token,
          expires_at: :os.system_time(:seconds) + expires_in
        }

        case Map.get(decoded_body, "refresh_token") do
          nil -> {:ok, state}
          value -> {:ok, Map.merge(state, %{refresh_token: value})}
        end

      _ ->
        Logger.debug("[Spotify] Could not refresh access token.")
        :error
    end
  end

  ### GenServer callbacks.

  @impl true
  def handle_call(:get_access_token, _from, state) do
    access_token = Map.get(state, :access_token)
    expires_at = Map.get(state, :expires_at)
    refresh_token = Map.get(state, :refresh_token)

    if expires_at < :os.system_time(:seconds) do
      case refresh_access_token(refresh_token) do
        {:ok, state} -> {:reply, Map.get(state, :access_token), state}
        :error -> {:stop, "Could not refresh access token.", state}
      end
    else
      {:reply, access_token, state}
    end
  end

  @impl true
  def handle_call(:get_refresh_token, _from, state) do
    {:reply, Map.get(state, :refresh_token), state}
  end

  @impl true
  def handle_call(:is_authorized?, _from, state) do
    refresh_token = Map.get(state, :refresh_token)

    case refresh_token do
      nil -> {:reply, false, state}
      _ -> {:reply, true, state}
    end
  end

  @impl true
  def handle_cast(:authorize, state) do
    query = %{
      client_id: client_id(),
      response_type: "code",
      redirect_uri: redirect_uri(),
      scope: "playlist-modify-public playlist-modify-private",
      show_dialog: "true"
    }

    authorization_url = "https://accounts.spotify.com/authorize?" <> URI.encode_query(query)

    Listmonk.send_transactional_email(
      listmonk_authorization_template_id(),
      data: %{"spotify_authorization_url" => authorization_url},
      subscriber_email: admin_email()
    )

    Logger.notice("[Spotify] Authorize at: #{authorization_url}")

    {:noreply, state}
  end

  @impl true
  def handle_cast({:handle_authorization, code}, state) do
    url = "https://accounts.spotify.com/api/token"

    body =
      {:form,
       [{"grant_type", "authorization_code"}, {"code", code}, {"redirect_uri", redirect_uri()}]}

    case Util.request(:post, url, body, headers()) do
      {:ok, body} ->
        %{
          "access_token" => access_token,
          "expires_in" => expires_in,
          "refresh_token" => refresh_token
        } = Poison.decode!(body)

        Logger.debug("[Spotify] Successfully authorized application.")

        {:noreply,
         %{
           state
           | access_token: access_token,
             expires_at: :os.system_time(:seconds) + expires_in,
             refresh_token: refresh_token
         }}

      :error ->
        Logger.debug("[Spotify] Could not authorize application.")
        {:noreply, state}
    end
  end
end
