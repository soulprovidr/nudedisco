defmodule Nudedisco.RSS.CacheWarmer do
  use Cachex.Warmer

  def interval, do: :timer.hours(1)

  # Returns the list of hydrated RSS feeds that should be cached when the cache warmer is executed.
  # Empty feeds are are not cached as there may be a previously-cached feed available that can be used instead.
  def execute(_args) do
    feeds =
      Nudedisco.RSS.hydrate_feeds()
      |> Enum.reject(fn {_k, v} -> v.items == nil end)

    {:ok, feeds}
  end
end
