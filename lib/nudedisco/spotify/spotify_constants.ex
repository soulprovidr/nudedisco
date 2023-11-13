defmodule Nudedisco.Spotify.Constants do
  @moduledoc """
  nudedisco Spotify constants.
  """

  @doc """
  Spotify API client ID.
  """
  @spec client_id() :: String.t()
  def client_id(), do: Application.get_env(:nudedisco, :spotify_client_id)

  @doc """
  Spotify API client secret.
  """
  @spec client_secret() :: String.t()
  def client_secret(), do: Application.get_env(:nudedisco, :spotify_client_secret)

  @doc """
  Spotify API redirect URI.
  """
  @spec redirect_uri() :: String.t()
  def redirect_uri(), do: Application.get_env(:nudedisco, :spotify_redirect_uri)
end
