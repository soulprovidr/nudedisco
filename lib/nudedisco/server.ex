defmodule Nudedisco.Server do
  use Ace.HTTP.Service, port: 8080, cleartext: true
  use Raxx.SimpleServer

  @impl Raxx.SimpleServer
  def handle_request(%{method: :GET, path: []}, _state) do
    case Poison.encode(Nudedisco.get_the_guardian_reviews()) do
      {:ok, json} ->
        response(:ok)
        |> set_header("content_type", "application/json")
        |> set_body(json)
      {:error, _exception} ->
        response(500)
        |> set_header("content_type", "text/plain")
        |> set_body("Could not decode content source.")
    end
  end

  def handle_request(%{method: :GET, path: _}, _state) do
    response(:not_found)
    |> set_header("content_type", "text/plain")
    |> set_body("Not found.")
  end
end
