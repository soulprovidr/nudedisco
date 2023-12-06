defmodule Nudedisco.Web.Controllers.Subscriptions do
  use Raxx.SimpleServer

  alias Nudedisco.Playlist

  require Logger

  def handle_request(%{method: :POST, path: ["subscriptions"], body: body}, _) do
    with %{"email" => email} <- URI.decode_query(body),
         {:ok, _} <- Playlist.Notification.create_subscriber(email) do
      redirect("/subscriptions/success")
    else
      _ -> redirect("/subscriptions/error")
    end
  end

  def handle_request(%{method: :GET, path: ["subscriptions", "success"]}, _) do
    response(:ok)
    |> set_header("content-type", "text/html")
    |> set_body(Nudedisco.Web.Templates.subscription_success())
  end

  def handle_request(%{method: :GET, path: ["subscriptions", "error"]}, _) do
    response(:ok)
    |> set_header("content-type", "text/html")
    |> set_body(Nudedisco.Web.Templates.subscription_error())
  end

  @impl Raxx.SimpleServer
  def handle_request(_, _) do
    response(:not_implemented)
  end
end
