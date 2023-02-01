defmodule Nudedisco.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Nudedisco.Cache, name: :nudedisco_cache},
      {Nudedisco.Web, name: :nudedisco_web}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
