defmodule Nudedisco.Web.Controllers.Home do
  use Raxx.SimpleServer

  alias Nudedisco.RSS
  alias Nudedisco.Web

  require Logger

  @impl Raxx.SimpleServer
  def handle_request(%{method: :GET, path: []}, _) do
    feeds = RSS.get_feeds()

    response(:ok)
    |> set_header("content-type", "text/html")
    |> set_body(
      Web.Templates.index([
        Web.Templates.headlines_section([
          {Map.get(feeds, :bandcamp), 8},
          {Map.get(feeds, :the_guardian), 6},
          {Map.get(feeds, :npr), 6}
        ]),
        Web.Templates.images_section({Map.get(feeds, :pitchfork), 4}),
        Web.Templates.headlines_section([
          {Map.get(feeds, :nme), 6},
          {Map.get(feeds, :rolling_stone), 6},
          {Map.get(feeds, :popmatters), 7}
        ]),
        Web.Templates.images_section({Map.get(feeds, :the_needledrop), 4}),
        Web.Templates.headlines_section([
          {Map.get(feeds, :the_quietus), 9},
          {Map.get(feeds, :backseat_mafia), 5},
          {Map.get(feeds, :beatsperminute), 8}
        ])
      ])
    )
  end

  @impl Raxx.SimpleServer
  def handle_request(_, _) do
    response(:not_implemented)
  end
end
