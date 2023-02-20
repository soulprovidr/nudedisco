defmodule Nudedisco.Cache.Warmer do
  use Cachex.Warmer

  def interval, do: :timer.hours(1)

  def execute(_args) do
    feeds = Nudedisco.get_feeds()
    {:ok, [{"feeds", feeds}]}
  end
end
