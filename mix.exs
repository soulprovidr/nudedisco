defmodule Nudedisco.MixProject do
  use Mix.Project

  def project do
    [
      app: :nudedisco,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Nudedisco.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ace, "~> 0.19.0"},
      {:mime, "~> 2.0"},
      {:raxx, "~> 1.1"},
      {:httpoison, "~> 1.8"},
      {:sweet_xml, "~> 0.7.1"}
    ]
  end
end
