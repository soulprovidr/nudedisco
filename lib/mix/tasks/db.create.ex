defmodule Mix.Tasks.Db.Create do
  @moduledoc """
  Create the database for all configured repositories.
  """

  use Mix.Task

  @requirements ["app.config"]

  def run(_) do
    repos()
    |> Enum.each(fn repo ->
      repo.__adapter__.storage_up(repo.config)
    end)

    Mix.shell().info("Database created successfully")
  end

  defp repos do
    Application.load(:nudedisco)
    Application.get_env(:nudedisco, :ecto_repos)
  end
end
