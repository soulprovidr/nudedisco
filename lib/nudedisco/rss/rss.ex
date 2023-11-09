defmodule Nudedisco.RSS do
  use GenServer

  def configs(), do: Nudedisco.RSS.Constants.feed_configs()

  @spec slugs() :: list(String.t())
  def slugs(), do: Enum.map(configs(), fn config -> config.slug end)

  @impl true
  def init(_args) do
    if sync_feeds!() do
      {:ok, nil}
    else
      {:stop, "Could not initialize RSS module."}
    end
  end

  @doc """
  Returns a map of hydrated RSS feeds.
  """
  @spec get_feeds :: %{atom() => Nudedisco.RSS.Feed.t()}
  def get_feeds do
    slugs()
    |> Enum.map(&Nudedisco.Cache.get!/1)
    |> Enum.into(%{}, fn feed -> {feed.slug, feed} end)
  end

  @doc """
  Hydrates and caches all RSS feeds.
  """
  @spec sync_feeds!() :: boolean()
  def sync_feeds!() do
    IO.puts("Syncing RSS feeds...")

    configs()
    |> Task.async_stream(
      &Nudedisco.RSS.Config.hydrate/1,
      ordered: false,
      timeout: 30 * 1000
    )
    |> Enum.reject(fn {:ok, feed} -> is_nil(feed.items) end)
    |> Enum.map(fn {:ok, feed} -> {feed.slug, feed} end)
    |> Nudedisco.Cache.put_many!()
  end

  def start_link(_args) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end
end
