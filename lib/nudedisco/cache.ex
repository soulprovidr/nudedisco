defmodule Nudedisco.Cache do
  @moduledoc """
  nudedisco cache module.

  Provides a simple interface for caching data (`fetch`, `get`, and `put`).

  The cache is a Cachex instance, and is configured to use the `:nudedisco` cache name.

  The cache is also configured to use a `Nudedisco.RSS.CacheWarmer` warmer, which is responsible
  for hydrating and caching RSS feeds.
  """

  import Cachex.Spec

  @cache_name :nudedisco

  @spec fetch(any, nil | fun, keyword) ::
          {:commit, any} | {:error, any} | {:ignore, any} | {:ok, any} | {:commit, any, any}
  def fetch(key, fallback, options) do
    Cachex.fetch(@cache_name, key, fallback, options)
  end

  @spec get(any) :: any
  def get(key) do
    Cachex.get!(@cache_name, key)
  end

  @spec put(any, any, keyword) :: any
  def put(key, value, options) do
    Cachex.put!(@cache_name, key, value, options)
  end

  def child_spec(_init_arg) do
    %{
      id: @cache_name,
      type: :supervisor,
      start:
        {Cachex, :start_link,
         [
           @cache_name,
           [
             warmers: [
               warmer(module: Nudedisco.RSS.CacheWarmer, state: nil)
             ]
           ]
         ]}
    }
  end
end
