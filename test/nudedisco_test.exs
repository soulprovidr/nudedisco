defmodule NudediscoTest do
  use ExUnit.Case, async: true

  defp assert_feed(feed, count) do
    assert is_bitstring(feed.name)
    assert length(feed.items) == count
    Enum.all?(feed.items, &assert_item_fields/1)
  end

  defp assert_feed_with_images(feed, count) do
    assert_feed(feed, count)
    Enum.all?(feed.items, &assert_image_field/1)
  end

  defp assert_item_fields(map) do
    assert is_bitstring(map.title)
    assert is_bitstring(map.description)
    assert is_bitstring(map.url)
    assert is_bitstring(map.date)
  end

  defp assert_image_field(map) do
    assert Map.has_key?(map, :image)
    assert is_bitstring(map.image)
  end

  test "fetches articles from The Needledrop" do
    feed = Nudedisco.get_the_needledrop_feed()
    assert_feed_with_images(feed, 4)
  end

  test "fetches album reviews from NME" do
    feed = Nudedisco.get_nme_reviews_feed()
    assert_feed(feed, 3)
  end

  test "fetches best new albums from Pitchfork" do
    feed = Nudedisco.get_pitchfork_best_albums_feed()
    assert_feed(feed, 3)
  end

  test "fetches album reviews from Pitchfork" do
    feed = Nudedisco.get_pitchfork_reviews_feed()
    assert_feed_with_images(feed, 4)
  end

  test "fetches album reviews from Rolling Stone" do
    feed = Nudedisco.get_rolling_stone_reviews_feed()
    assert_feed(feed, 4)
  end

  test "fetches album reviews from The Guardian" do
    feed = Nudedisco.get_the_guardian_reviews_feed()
    assert_feed(feed, 6)
  end

  test "fetches album reviews from The Quietus" do
    feed = Nudedisco.get_the_quietus_reviews_feed()
    assert_feed(feed, 4)
  end
end
