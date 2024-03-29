defmodule WebTest do
  use ExUnit.Case, async: true

  alias Nudedisco.RSS

  test "displays RSS feeds on the homepage" do
    port = Application.get_env(:nudedisco, :port)
    url = "http://localhost:#{port}/"

    feeds = RSS.get_feeds()

    response = HTTPoison.get!(url)
    assert response.status_code == 200

    Enum.all?(feeds, fn feed ->
      assert String.contains?(response.body, feed.name)
    end)
  end
end
