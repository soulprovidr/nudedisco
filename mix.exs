defmodule Nudedisco.MixProject do
  use Mix.Project

  def project do
    [
      app: :nudedisco,
      version: "1.0.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Nudedisco.Application, []}
    ]
  end

  defp deps do
    [
      {:ace, "~> 0.19.0"},
      {:cachex, "~> 3.6"},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:mime, "~> 2.0"},
      {:raxx, "~> 1.1"},
      {:httpoison, "~> 1.8"},
      {:poison, "~> 5.0"},
      {:quantum, "~> 3.0"},
      {:sweet_xml, "~> 0.7.1"}
    ]
  end
end
