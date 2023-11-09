defmodule Nudedisco.Cache do
  @moduledoc """
  nudedisco cache module.

  Provides a simple interface for caching data (`fetch`, `get`, `put`, and `put_many`).
  """

  @cache_name :nudedisco

  @spec fetch(any, any, keyword) :: any
  def fetch(key, fallback, options \\ []) do
    Cachex.fetch(@cache_name, key, fallback, options)
  end

  @spec get!(any) :: any
  def get!(key) do
    Cachex.get!(@cache_name, key)
  end

  @spec put!(any, any, keyword) :: any
  def put!(key, value, options) do
    Cachex.put!(@cache_name, key, value, options)
  end

  @spec put_many!([{any(), any()}], Keyword.t()) :: true | false
  def put_many!(entries, options \\ []) do
    Cachex.put_many!(@cache_name, entries, options)
  end

  def child_spec(_init_arg) do
    %{
      id: __MODULE__,
      type: :supervisor,
      start:
        {Cachex, :start_link,
         [
           @cache_name,
           []
         ]}
    }
  end
end
