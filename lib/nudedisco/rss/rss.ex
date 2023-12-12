defmodule Nudedisco.RSS do
  use GenServer

  alias Nudedisco.RSS
  alias Nudedisco.Repo
  alias Nudedisco.Util

  require Logger

  import Ecto.Query
  import SweetXml

  def configs(), do: Application.get_env(:nudedisco, RSS) |> Keyword.get(:configs, [])

  def start_link(_) do
    GenServer.start_link(__MODULE__, [])
  end

  def init(_) do
    sync()

    :ignore
  end

  defp get_feed_config(feed) do
    configs()
    |> Enum.find(fn config -> config.slug == feed.slug end)
  end

  defp load_items(feed) do
    case Util.request(:get, feed.feed_url) do
      {:ok, body} ->
        %{
          xpath_spec: xpath_spec,
          xpath_subspec: xpath_subspec
        } = get_feed_config(feed)

        xpath(body, xpath_spec, xpath_subspec)
        |> Enum.map(fn item -> Map.put(item, :feed_id, feed.id) end)

      _ ->
        Logger.error("Error reading " <> feed.feed_url <> ".")
        []
    end
  end

  def get_feeds(query \\ from(f in RSS.Feed)) do
    Repo.all(query) |> Repo.preload(items: from(i in RSS.Item, order_by: [desc: i.date]))
  end

  def get_items(query \\ from(i in RSS.Item)) do
    Repo.all(query)
  end

  def sync() do
    Logger.debug("[RSS] Syncing RSS feeds...")

    Repo.all(RSS.Feed)
    |> Task.async_stream(
      fn feed -> Repo.insert_all(RSS.Item, load_items(feed), on_conflict: :nothing) end,
      ordered: false,
      timeout: 30 * 1000
    )
    |> Stream.run()

    Logger.debug("[RSS] Successfully synced RSS feeds.")
  end
end
