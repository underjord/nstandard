defmodule Nstandard.MixProject do
  use Mix.Project

  def project do
    [
      app: :nstandard,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      consolidate_protocols: Mix.env() != :dev,
      deps: deps(),

      # Docs
      name: "Nstandard",
      description: "A standard library setup based on the Nerves project standard practices.",
      source_url: "https://github.com/underjord/nstandard",
      docs: docs(),
      package: package(),
      aliases: aliases(),
      dialyzer: [
        plt_add_apps: [:mix],
        ignore_warnings: ".dialyzer_ignore.exs"
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    [
      name: :nstandard,
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/underjord/nstandard"}
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md"]
    ]
  end

  defp deps do
    [
      {:spellweaver, "~> 0.1", optional: true},
      {:igniter, "~> 0.6", optional: true},
      # Linters are all optional because we want to put them in the dependant project
      {:ex_doc, "~> 0.31", optional: true, runtime: false},
      {:dialyxir, "~> 1.0", optional: true, runtime: false},
      {:credo, "~> 1.7", optional: true, runtime: false}
    ]
  end

  defp aliases do
    [
      check: [
        "compile --warnings-as-errors --force",
        "format --check-formatted",
        "credo",
        "dialyzer"
      ]
    ]
  end
end
