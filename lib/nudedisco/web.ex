defmodule Nudedisco.Web do
  use Ace.HTTP.Service, port: 8080, cleartext: true
  use Raxx.SimpleServer

  @impl Raxx.SimpleServer
  def handle_request(%{method: :GET, path: []}, _) do
    feeds = Nudedisco.get_all_feeds()
    response(:ok)
    |> set_header("content_type", "text/html")
    |> set_body(Nudedisco.Templates.index(feeds))
  end

  def handle_request(request = %{method: :GET, path: [_rest]}, _) do
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
          :enoent -> response(:not_found)
          _ -> response(:error)
        end
    end
  end

  def handle_request(%{method: :GET, path: _}, _) do
    response(:not_found)
  end
end
