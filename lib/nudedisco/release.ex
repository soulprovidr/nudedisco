defmodule Nudedisco.Release do
  @app :nudedisco

  def create_db do
    for repo <- repos() do
      repo.__adapter__.storage_up(repo.config)
    end
  end

  def migrate do
    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo, version) do
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp repos do
    Application.load(@app)
    Application.get_env(@app, :ecto_repos)
  end
end
