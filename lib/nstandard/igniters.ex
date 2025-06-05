defmodule Nstandard.Igniters do
  @moduledoc """
  Igniters for adding the standard parts to a mix project.
  """

  @deps [
    {:ex_doc, "~> 0.31", only: [:dev, :test], runtime: false},
    {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
    {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
    {:spellweaver, "~> 0.1", only: [:dev, :test], runtime: false}
  ]

  def add_docs(igniter) do
    app_name = Igniter.Project.Application.app_name(igniter)

    fancy_name =
      app_name
      |> to_string()
      |> String.replace("_", " ")
      |> String.capitalize()

    igniter
    |> new_project_string([:name], fancy_name)
    |> new_project_string(
      [:description],
      "TODO: write a proper description"
    )
    |> new_project_function(:docs, main: "readme", extras: ["README.md"])
  end

  def add_package(igniter) do
    app_name = Igniter.Project.Application.app_name(igniter)

    igniter
    |> new_project_function(:package,
      name: app_name,
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/TODO/#{app_name}"}
    )
  end

  def add_linters(igniter) do
    igniter =
      igniter
      |> new_project_function(:aliases,
        check: [
          "hex.audit",
          "compile --warnings-as-errors --force",
          "format --check-formatted",
          "credo",
          "deps.unlock --check-unused",
          "spellweaver.check",
          "dialyzer"
        ]
      )
      |> new_project_function(:dialyzer,
        plt_add_apps: [:mix],
        ignore_warnings: ".dialyzer_ignore.exs"
      )

    @deps
    |> Enum.reduce(igniter, fn dep, igniter ->
      Igniter.Project.Deps.add_dep(igniter, dep, append?: true)
    end)
  end

  def add_credo_config(igniter) do
    contents = """
    %{
      configs: [
        %{
          name: "default",
          files: %{
            included: ["lib/"],
          },
          strict: true,
          checks: [
            {Credo.Check.Refactor.MapInto, false},
            {Credo.Check.Warning.LazyLogging, false},
            {Credo.Check.Readability.LargeNumbers, only_greater_than: 86400},
            {Credo.Check.Readability.ParenthesesOnZeroArityDefs, parens: true},
            {Credo.Check.Readability.Specs, tags: []},
            {Credo.Check.Readability.StrictModuleLayout, tags: []}
          ]
        }
      ]
    }
    """

    igniter
    |> Igniter.create_new_file(".credo.exs", contents, on_exists: :warning)
  end

  def add_license(igniter) do
    license =
      :code.priv_dir(:nstandard)
      |> Path.join("LICENSE.md")
      |> File.read!()

    igniter
    |> Igniter.create_new_file("LICENSE.md", license, on_exists: :warning)
  end

  def add_changelog(igniter) do
    changelog = """
    # Changelog

    ## v0.1.0

    - TODO: write changelog
    """

    igniter
    |> Igniter.create_new_file("CHANGELOG.md", changelog, on_exists: :warning)
  end

  def add_dialyzer_ignore(igniter) do
    dialyzer_ignore =
      :code.priv_dir(:nstandard)
      |> Path.join(".dialyzer_ignore.exs")
      |> File.read!()

    igniter
    |> Igniter.create_new_file(".dialyzer_ignore.exs", dialyzer_ignore, on_exists: :warning)
  end

  def add_dependabot(igniter) do
    dependabot =
      :code.priv_dir(:nstandard)
      |> Path.join("github/dependabot.yml")
      |> File.read!()

    igniter
    |> Igniter.mkdir(".github")
    |> Igniter.create_new_file(".github/dependabot.yml", dependabot, on_exists: :warning)
  end

  def add_ci(igniter) do
    ci =
      :code.priv_dir(:nstandard)
      |> Path.join("github/ci.yml")
      |> File.read!()

    igniter
    |> Igniter.mkdir(".github")
    |> Igniter.create_new_file(".github/ci.yml", ci, on_exists: :warning)
  end

  defp new_project_function(igniter, function_name, kv_pairs) do
    igniter
    |> Igniter.Project.MixProject.update(:project, [function_name], fn zipper ->
      if zipper do
        {:ok, zipper}
      else
        {:ok,
         {:code,
          quote do
            unquote(function_name)()
          end}}
      end
    end)
    |> add_kv_pairs(function_name, kv_pairs)
  end

  defp add_kv_pairs(igniter, function_name, kv_pairs) do
    kv_pairs
    |> Enum.reduce(igniter, fn {key, value}, igniter ->
      igniter
      |> Igniter.Project.MixProject.update(function_name, [key], fn
        nil ->
          {:ok, {:code, {:__block__, [], [value]}}}

        zipper ->
          {:ok, zipper}
      end)
    end)
  end

  defp new_project_string(igniter, path, value) do
    igniter
    |> Igniter.Project.MixProject.update(:project, path, fn zipper ->
      if zipper do
        {:ok, zipper}
      else
        {:ok, {:code, {:__block__, [], [value]}}}
      end
    end)
  end
end
