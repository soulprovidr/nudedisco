defmodule Nudedisco.Web.Controllers.API do
  use Raxx.SimpleServer

  alias Nudedisco.Listmonk

  require Logger

  def handle_request(%{method: :POST, path: [_, "create_subscriber"], body: body}, _) do
    with {:ok, %{"email" => email}} <- Poison.decode(body),
         {:ok, _} <- Listmonk.create_subscriber(email) do
      Logger.debug("[Listmonk] Successfully created subscriber.")

      response(:ok)
    else
      _ ->
        Logger.debug("[Listmonk] Failed to create subscriber.")

        response(:error)
    end
  end

  @impl Raxx.SimpleServer
  def handle_request(_, _) do
    response(:not_implemented)
  end
end
