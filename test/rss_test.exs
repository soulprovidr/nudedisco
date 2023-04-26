defmodule RSSTest do
  use ExUnit.Case, async: true

  defp assert_feed(feed) do
    assert is_bitstring(feed.name)
    assert is_bitstring(feed.site_url)
    assert is_atom(feed.slug)

    if feed.items != nil do
      Enum.all?(feed.items, &assert_item_fields/1)
    end
  end

  defp assert_item_fields(map) do
    assert is_bitstring(map.title)
    assert is_bitstring(map.description)
    assert is_bitstring(map.url)
    assert is_bitstring(map.date)
  end

  test "cache populated when application starts" do
    feeds = Nudedisco.RSS.get_feeds()

    for {_k, v} <- feeds do
      assert_feed(v)
    end
  end

  test "hydrates RSS feeds appropriately" do
    feeds = Nudedisco.RSS.hydrate_feeds()

    for {_k, v} <- feeds do
      assert_feed(v)
    end
  end
end
