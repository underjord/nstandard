defmodule Nstandard.Igniters do
  @deps [
    {:ex_doc, "~> 0.31"},
    {:dialyxir, "~> 1.0"},
    {:credo, "~> 1.7"}
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
          "compile --warnings-as-errors --force",
          "format --check-formatted",
          "credo",
          "dialyzer"
        ]
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
    |> Igniter.create_new_file("CHANGELOG.md", changelog, on_exisxts: :warning)
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
    igniter =
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

    kv_pairs
    |> Enum.reduce(igniter, fn {key, value}, igniter ->
      igniter
      |> Igniter.Project.MixProject.update(function_name, [key], fn zipper ->
        if zipper do
          {:ok, zipper}
        else
          {:ok, {:code, value}}
        end
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
