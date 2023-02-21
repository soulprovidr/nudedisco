defmodule Nudedisco.Web do
  use Ace.HTTP.Service, port: 8080, cleartext: true
  use Raxx.SimpleServer

  defp read_file_from_path(path) do
    file_path = Path.join(:code.priv_dir(:nudedisco), Path.join(path))

    case File.read(file_path) do
      {:ok, file} ->
        mime_type = MIME.from_path(file_path)
        {:ok, file, mime_type}

      {:error, exception} ->
        {:error, exception}
    end
  end

  @impl Raxx.SimpleServer
  def handle_request(%{method: :GET, path: []}, _) do
    feeds = Cachex.get!(:cache, "feeds")

    response(:ok)
    |> set_header("content_type", "text/html")
    |> set_body(
      Nudedisco.Templates.index([
        Nudedisco.Templates.headlines_section([
          [feeds.bandcamp, 8],
          [feeds.the_guardian, 6],
          [feeds.npr, 6]
        ]),
        Nudedisco.Templates.images_section([feeds.pitchfork, 4]),
        Nudedisco.Templates.headlines_section([
          [feeds.nme, 6],
          [feeds.rolling_stone, 6],
          [feeds.popmatters, 7]
        ]),
        Nudedisco.Templates.images_section([feeds.the_needledrop, 4]),
        Nudedisco.Templates.headlines_section([
          [feeds.the_quietus, 10],
          [feeds.backseat_mafia, 6],
          [feeds.beatsperminute, 8]
        ])
      ])
    )
  end

  def handle_request(%{method: :HEAD, path: []}, _) do
    response(:ok)
  end

  def handle_request(request = %{method: :GET, path: [_rest]}, _) do
    case read_file_from_path(request.path) do
      {:ok, file, mime_type} ->
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

  def handle_request(request = %{method: :HEAD, path: [_rest]}, _) do
    case read_file_from_path(request.path) do
      {:ok, _file, mime_type} ->
        response(:ok)
        |> set_header("content_type", mime_type)

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

  def handle_request(%{method: :HEAD, path: _}, _) do
    response(:not_found)
  end
end
