defmodule Nudedisco.Web.Controllers.Error do
  use Raxx.SimpleServer

  @impl Raxx.SimpleServer
  def handle_request(_, _) do
    response(:not_implemented)
  end
end
