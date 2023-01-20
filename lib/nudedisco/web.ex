defmodule Nudedisco.Web do
  use Ace.HTTP.Service, port: 8080, cleartext: true
  use Raxx.SimpleServer

  def error_response(status, body) do
    response(status)
    |> set_header("content_type", "text/plain")
    |> set_body(body)
  end

  @impl Raxx.SimpleServer
  def handle_request(%{method: :GET, path: []}, _state) do
    case Poison.encode(Nudedisco.get_the_guardian_reviews()) do
      {:ok, json} ->
        response(:ok)
        |> set_header("content_type", "application/json")
        |> set_body(json)
      {:error, _exception} ->
        error_response(500, "Could not decode content source.")
    end
  end

  def handle_request(request = %{method: :GET, path: ["static" | _rest]}, _state) do
    request_path = Path.join(request.path)
    file_path = Path.join(:code.priv_dir(:nudedisco), request_path)
    case File.read(file_path) do
      {:ok, file} ->
        mime_type = MIME.from_path(file_path)
        response(:ok)
        |> set_header("content_type", mime_type)
        |> set_body(file)
      {:error, exception} ->
        case exception do
          :enoent -> error_response(404, "File not found.")
          _ -> error_response(500, "Error reading file.")
        end
    end
  end

  def handle_request(%{method: :GET, path: _}, _state) do
    response(:not_found)
    |> set_header("content_type", "text/plain")
    |> set_body(Nudedisco.Templates.index)
  end
end
