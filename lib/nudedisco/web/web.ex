defmodule Nudedisco.Web do
  @moduledoc """
  Handles all HTTP requests and serves the web app.
  """

  use Ace.HTTP.Service,
    port: Application.compile_env(:nudedisco, :port),
    cleartext: true

  use Raxx.Router

  alias Nudedisco.Web.Controllers.Home, as: HomeController
  # alias Nudedisco.Web.Controllers.Spotify, as: SpotifyController
  alias Nudedisco.Web.Controllers.Static, as: StaticController
  alias Nudedisco.Web.Controllers.Error, as: ErrorController

  section([], [
    {%{method: :GET, path: []}, HomeController},
    # {%{method: :GET, path: ["spotify", _rest]}, SpotifyController},
    {%{method: :GET, path: _}, StaticController},
    {_, ErrorController}
  ])
end
