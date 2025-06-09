defmodule Nudedisco.MixProject do
  use Mix.Project

  def project do
    [
      app: :nudedisco,
      version: "1.0.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Nudedisco.Application, []}
    ]
  end

  defp aliases do
    [setup: ["ecto.drop", "ecto.create", "ecto.migrate", "db.migrate", "rss.init", "db.populate_feeds"]]
  end

  defp deps do
    [
      {:ace, "~> 0.19.0"},
      {:cachex, "~> 3.6"},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:ecto_sql, "~> 3.0"},
      {:ecto_sqlite3, "~> 0.13"},
      {:mime, "~> 2.0"},
      {:raxx, "~> 1.1"},
      {:httpoison, "~> 1.8"},
      {:poison, "~> 5.0"},
      {:quantum, "~> 3.0"},
      {:sweet_xml, "~> 0.7.1"},
      {:timex, "~> 3.0"},
      {:tzdata, "~> 1.1"}
    ]
  end
end
