defmodule Nudedisco.Cache do
  import Cachex.Spec

  @cache_table :cache

  def child_spec(_init_arg) do
    %{
      id: @cache_table,
      type: :supervisor,
      start:
        {Cachex, :start_link,
         [
           @cache_table,
           [
             warmers: [
               warmer(module: Nudedisco.Cache.Warmer, state: nil)
             ]
           ]
         ]}
    }
  end

  def get(key) do
    Cachex.get!(@cache_table, key)
  end
end
