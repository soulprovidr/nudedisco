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
    assert Timex.is_valid?(map.date)
  end

  test "applications starts -> feeds populated" do
    feeds = Nudedisco.RSS.get_feeds()

    for {_k, v} <- feeds do
      assert_feed(v)
    end
  end

  test "syncs RSS feeds every hour" do
    import Crontab.CronExpression
    job = Nudedisco.Scheduler.find_job(:rss_sync)
    assert job != nil
    assert job.schedule == ~e"@hourly"
  end
end
