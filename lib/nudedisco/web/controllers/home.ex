defmodule Nudedisco.Web.Controllers.Home do
  use Raxx.SimpleServer

  alias Nudedisco.Web.Templates, as: Templates

  @impl Raxx.SimpleServer
  def handle_request(%{method: :GET, path: []}, _) do
    feeds = Nudedisco.RSS.get_feeds()

    response(:ok)
    |> set_header("content-type", "text/html")
    |> set_body(
      Templates.index([
        Templates.headlines_section([
          {Map.get(feeds, :bandcamp), 8},
          {Map.get(feeds, :the_guardian), 6},
          {Map.get(feeds, :npr), 6}
        ]),
        Templates.images_section({Map.get(feeds, :pitchfork), 4}),
        Templates.headlines_section([
          {Map.get(feeds, :nme), 6},
          {Map.get(feeds, :rolling_stone), 6},
          {Map.get(feeds, :popmatters), 7}
        ]),
        Templates.images_section({Map.get(feeds, :the_needledrop), 4}),
        Templates.headlines_section([
          {Map.get(feeds, :the_quietus), 9},
          {Map.get(feeds, :backseat_mafia), 5},
          {Map.get(feeds, :beatsperminute), 8}
        ])
      ])
    )
  end

  def handle_request(%{method: :GET, path: ["about"]}, _) do
    response(:ok)
    |> set_header("content-type", "text/html")
    |> set_body("About")
  end
end
