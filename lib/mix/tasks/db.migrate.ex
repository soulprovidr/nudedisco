defmodule Mix.Tasks.Db.Migrate do
  @moduledoc """
  Run database migrations for all configured repositories.
  """

  use Mix.Task

  @requirements ["app.config"]

  def run(_) do
    repos()
    |> Enum.each(fn repo ->
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end)

    Mix.shell().info("Database migrations completed successfully")
  end

  defp repos do
    Application.load(:nudedisco)
    Application.get_env(:nudedisco, :ecto_repos)
  end
end
