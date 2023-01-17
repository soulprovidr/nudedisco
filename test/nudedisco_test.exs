defmodule NudediscoTest do
  use ExUnit.Case, async: true

  test "fetches best new albums from Pitchfork" do
    items = Nudedisco.get_pitchfork_best_albums()
    assert Enum.all?(items, &match?(%Nudedisco.Item{}, &1))
  end

  test "fetches album reviews from The Guardian" do
    items = Nudedisco.get_the_guardian_reviews()
    assert Enum.all?(items, &match?(%Nudedisco.Item{}, &1))
  end
end
