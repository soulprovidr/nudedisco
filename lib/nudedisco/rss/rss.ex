defmodule Nudedisco.RSS do
  alias Nudedisco.RSS
  alias Nudedisco.Repo

  import Ecto.Query

  def child_spec(opts \\ []) do
    %{
      id: RSS,
      start: {RSS.Sync, :start_link, [opts]},
      type: :worker
    }
  end

  def get_feeds(query \\ from(f in RSS.Feed)) do
    Repo.all(query) |> Repo.preload(items: from(i in RSS.Item, order_by: [desc: i.date]))
  end

  def get_items(query \\ from(i in RSS.Item)) do
    Repo.all(query)
  end
end
