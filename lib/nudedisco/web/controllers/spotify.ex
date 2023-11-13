defmodule Nudedisco.Web.Controllers.Spotify do
  use Raxx.SimpleServer

  alias Nudedisco.Spotify

  @impl Raxx.SimpleServer
  def handle_request(%{method: :GET, path: ["spotify", "callback"], query: query}, _) do
    IO.puts("[Spotify] Attempting to obtain refresh token...")

    with %{"code" => code} <- URI.decode_query(query),
         :ok <- Spotify.Auth.handle_authorization(code) do
      response(:ok)
      |> set_body("Spotify authorization successful!")
    else
      %{"error" => error} ->
        response(:error)
        |> set_body("Spotify authorization failed with error: #{error}")

      _ ->
        response(:error)
        |> set_body("Spotify authorization failed.")
    end
  end
end
