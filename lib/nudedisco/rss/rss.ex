defmodule Nudedisco.RSS do
  use GenServer

  alias Nudedisco.RSS

  require Logger

  @type state :: %{
          atom() => RSS.Feed.t()
        }

  @update_interval 60 * 60 * 1000

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_) do
    {:noreply, state} = handle_info(:update, %{})
    {:ok, state}
  end

  @doc """
  Returns a map of hydrated RSS feeds.
  """
  @spec get_feeds :: %{atom() => RSS.Feed.t()}
  def get_feeds do
    GenServer.call(__MODULE__, :get_feeds)
  end

  @spec get_feed_configs() :: [RSS.Feed.Config.t()]
  defp get_feed_configs() do
    Application.get_env(:nudedisco, RSS)
    |> Keyword.get(:feed_configs, [])
  end

  @spec hydrate_feeds() :: state()
  defp hydrate_feeds() do
    get_feed_configs()
    |> Task.async_stream(&RSS.Config.hydrate/1,
      ordered: false,
      timeout: 30 * 1000
    )
    |> Enum.reject(fn {:ok, feed} -> is_nil(feed.items) end)
    |> Enum.into(%{}, fn {:ok, feed} -> {feed.slug, feed} end)
  end

  defp schedule_update do
    Process.send_after(self(), :update, @update_interval)
  end

  @impl true
  def handle_call(:get_feeds, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_info(:update, state) do
    Logger.debug("[RSS] Updating RSS feeds...")
    new_state = Map.merge(state, hydrate_feeds())
    Logger.debug("[RSS] Updated RSS feeds.")
    schedule_update()
    {:noreply, new_state}
  end
end
