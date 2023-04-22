defmodule Nudedisco.Web.Controllers.Home do
  use Raxx.SimpleServer

  alias Nudedisco.Web.Templates, as: Templates

  @impl Raxx.SimpleServer
  def handle_request(%{method: :GET, path: []}, _) do
    feeds = Nudedisco.RSS.get_feeds()

    response(:ok)
    |> set_header("content_type", "text/html")
    |> set_body(
      Templates.index([
        Templates.headlines_section([
          {feeds.bandcamp, 8},
          {feeds.the_guardian, 6},
          {feeds.npr, 6}
        ]),
        Templates.images_section({feeds.pitchfork, 4}),
        Templates.headlines_section([
          {feeds.nme, 6},
          {feeds.rolling_stone, 6},
          {feeds.popmatters, 7}
        ]),
        Templates.images_section({feeds.the_needledrop, 4}),
        Templates.headlines_section([
          {feeds.the_quietus, 9},
          {feeds.backseat_mafia, 5},
          {feeds.beatsperminute, 8}
        ])
      ])
    )
  end

  def handle_request(%{method: :GET, path: ["about"]}, _) do
    response(:ok)
    |> set_header("content_type", "text/html")
    |> set_body("About")
  end
end
