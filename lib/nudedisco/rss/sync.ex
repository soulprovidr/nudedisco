defmodule Nudedisco.RSS.Sync do
  use GenServer

  alias Nudedisco.RSS
  alias Nudedisco.Repo
  alias Nudedisco.Util

  require Logger

  import SweetXml

  def start_link(_) do
    GenServer.start_link(__MODULE__, [])
  end

  def init(_) do
    run()

    :ignore
  end

  defp load_items(feed) do
    case Util.request(:get, feed.feed_url) do
      {:ok, body} ->
        %{
          xpath_spec: xpath_spec,
          xpath_subspec: xpath_subspec
        } = RSS.get_feed_config(feed)

        xpath(body, xpath_spec, xpath_subspec)
        |> Enum.map(fn item -> Map.put(item, :feed_id, feed.id) end)

      _ ->
        Logger.error("Error reading " <> feed.feed_url <> ".")
        []
    end
  end

  def run() do
    Logger.debug("[RSS] Syncing RSS feeds...")

    Repo.all(RSS.Feed)
    |> Task.async_stream(
      fn feed -> Repo.insert_all(RSS.Item, load_items(feed), on_conflict: :nothing) end,
      max_concurrency: 3,
      ordered: false,
      timeout: 30 * 1000
    )
    |> Stream.run()

    Logger.debug("[RSS] Successfully synced RSS feeds.")
  end
end
