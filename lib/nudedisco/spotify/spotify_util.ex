defmodule Nudedisco.Spotify.Util do
  alias Nudedisco.Spotify
  alias Nudedisco.Util

  @doc """
  Make an authenticated request to the Spotify API.
  """
  @spec request(atom, String.t(), String.t(), [{String.t(), String.t()}]) ::
          {:ok, any} | :error
  def request(method, url, body \\ "", headers \\ []) do
    with access_token when access_token != nil <- Spotify.Auth.get_access_token(),
         {:ok, body} <-
           Util.request(method, url, body, [
             {"Authorization", "Bearer #{access_token}}"} | headers
           ]) do
      {:ok, Poison.decode!(body)}
    else
      _ ->
        :error
    end
  end
end
