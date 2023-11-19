defmodule Nudedisco.Web.Controllers.Static do
  use Raxx.SimpleServer

  defp read_file_from_path(path) do
    public_dir = Path.join(:code.priv_dir(:nudedisco), "public")
    file_path = Path.join(public_dir, Path.join(path))

    with {:ok, file} <- File.read(file_path) do
      mime_type = MIME.from_path(file_path)
      {:ok, file, mime_type}
    else
      {:error, exception} ->
        {:error, exception}
    end
  end

  @impl Raxx.SimpleServer
  def handle_request(request = %{method: :GET, path: [_rest]}, _) do
    with {:ok, file, mime_type} <- read_file_from_path(request.path) do
      response(:ok)
      |> set_header("content-type", mime_type)
      |> set_body(file)
    else
      {:error, :enoent} -> response(:not_found)
      {:error, _} -> response(:error)
    end
  end
end
