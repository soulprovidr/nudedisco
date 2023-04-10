defmodule Nudedisco.RSS.CacheWarmer do
  use Cachex.Warmer

  def interval, do: :timer.hours(1)

  def execute(_args) do
    # TODO: Only update feeds that have items.
    {:ok, Nudedisco.RSS.hydrate_feeds()}
  end
end
