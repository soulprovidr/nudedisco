defmodule Nudedisco.Web.Controllers.Home do
  use Raxx.SimpleServer

  alias Nudedisco.RSS
  alias Nudedisco.Web

  @impl Raxx.SimpleServer
  def handle_request(%{method: :GET, path: []}, _) do
    feeds_by_slug =
      RSS.get_feeds()
      |> Enum.into(%{}, fn feed -> {feed.slug, feed} end)

    response(:ok)
    |> set_header("content-type", "text/html")
    |> set_header("content-security-policy", "frame-src 'none'")
    |> set_body(
      Web.Templates.index([
        Web.Templates.headlines_section([
          {Map.get(feeds_by_slug, "bandcamp"), 8},
          {Map.get(feeds_by_slug, "the_guardian"), 6},
          {Map.get(feeds_by_slug, "npr"), 6}
        ]),
        Web.Templates.images_section({Map.get(feeds_by_slug, "pitchfork"), 4}),
        Web.Templates.headlines_section([
          {Map.get(feeds_by_slug, "nme"), 6},
          {Map.get(feeds_by_slug, "rolling_stone"), 6},
          {Map.get(feeds_by_slug, "popmatters"), 7}
        ]),
        Web.Templates.images_section({Map.get(feeds_by_slug, "the_needledrop"), 4}),
        Web.Templates.headlines_section([
          {Map.get(feeds_by_slug, "the_quietus"), 9},
          {Map.get(feeds_by_slug, "backseat_mafia"), 5},
          {Map.get(feeds_by_slug, "beatsperminute"), 8}
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
