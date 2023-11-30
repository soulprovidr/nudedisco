defmodule Nudedisco.RSS do
  use GenServer

  alias Nudedisco.RSS

  require Logger

  @type state :: %{
          atom() => RSS.Feed.t()
        }

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_) do
    {:noreply, state} = handle_cast(:sync, %{})
    {:ok, state}
  end

  @doc """
  Returns a map of hydrated RSS feeds.
  """
  @spec get_feeds :: %{atom() => RSS.Feed.t()}
  def get_feeds do
    GenServer.call(__MODULE__, :get_feeds)
  end

  @spec get_configs() :: [RSS.Config.t()]
  defp get_configs() do
    Application.get_env(:nudedisco, RSS)
    |> Keyword.get(:configs, [])
  end

  @spec hydrate_feeds() :: state()
  defp hydrate_feeds() do
    get_configs()
    |> Task.async_stream(&RSS.Config.hydrate/1,
      ordered: false,
      timeout: 30 * 1000
    )
    |> Enum.reject(fn {:ok, feed} -> is_nil(feed.items) end)
    |> Enum.into(%{}, fn {:ok, feed} -> {feed.slug, feed} end)
  end

  def sync() do
    GenServer.cast(__MODULE__, :sync)
  end

  @impl true
  def handle_call(:get_feeds, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_cast(:sync, state) do
    Logger.debug("[RSS] Syncing RSS feeds...")
    new_state = Map.merge(state, hydrate_feeds())
    Logger.debug("[RSS] Successfully synced RSS feeds.")
    {:noreply, new_state}
  end
end
