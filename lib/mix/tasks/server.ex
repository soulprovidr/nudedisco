defmodule Mix.Tasks.Server do
  @moduledoc """
  Start the Nudedisco application server.
  """

  use Mix.Task

  @requirements ["app.start"]

  def run(_) do
    Mix.shell().info("Starting Nudedisco server...")

    # Ensure all applications are started
    {:ok, _} = Application.ensure_all_started(:nudedisco)

    Mix.shell().info("Nudedisco server started successfully")

    # Keep the process alive
    Process.sleep(:infinity)
  end
end
