defmodule Mix.Tasks.Nstandard.InstallTest do
  use ExUnit.Case, async: true
  import Igniter.Test

  test "project is set up according to the nerves standard practices" do
    test_project()
    |> Igniter.compose_task("nstandard.install", [])
    # Verify files are created
    |> assert_creates(".credo.exs")
    |> assert_creates(".dialyzer_ignore.exs")
    |> assert_creates("LICENSE.md")
    |> assert_creates("CHANGELOG.md")
    # Verify dependencies are added to mix.exs
    |> assert_has_patch(
      "mix.exs",
      " + |      {:ex_doc, \"~> 0.31\", only: [:dev, :test], runtime: false},"
    )
    |> assert_has_patch(
      "mix.exs",
      " + |      {:dialyxir, \"~> 1.0\", only: [:dev, :test], runtime: false},"
    )
    |> assert_has_patch(
      "mix.exs",
      " + |      {:credo, \"~> 1.7\", only: [:dev, :test], runtime: false}"
    )
    # Verify aliases are added
    |> assert_has_patch("mix.exs", " + |      check: [")
    |> assert_has_patch(
      "mix.exs",
      " + |        \"compile --warnings-as-errors --force\","
    )
    |> assert_has_patch("mix.exs", " + |        \"format --check-formatted\",")
    |> assert_has_patch("mix.exs", " + |        \"credo\",")
    |> assert_has_patch("mix.exs", " + |        \"dialyzer\"")
    # Verify dialyzer configuration is added
    |> assert_has_patch("mix.exs", " + |      plt_add_apps: [:mix],")
    |> assert_has_patch("mix.exs", " + |      ignore_warnings: \".dialyzer_ignore.exs\"")
  end

  test "adds proper credo configuration" do
    test_project()
    |> Igniter.compose_task("nstandard.install", [])
    |> assert_has_patch(
      ".credo.exs",
      """
      1  |%{
      2  |  configs: [
      3  |    %{
      4  |      name: "default",
      5  |      files: %{
      6  |        included: ["lib/"]
      7  |      },
      8  |      strict: true,
      9  |      checks: [
      10 |        {Credo.Check.Refactor.MapInto, false},
      11 |        {Credo.Check.Warning.LazyLogging, false},
      12 |        {Credo.Check.Readability.LargeNumbers, only_greater_than: 86400},
      13 |        {Credo.Check.Readability.ParenthesesOnZeroArityDefs, parens: true},
      14 |        {Credo.Check.Readability.Specs, tags: []},
      15 |        {Credo.Check.Readability.StrictModuleLayout, tags: []}
      16 |      ]
      17 |    }
      18 |  ]
      19 |}
      20 |
      """
    )
  end

  test "adds package configuration with proper links and license" do
    test_project()
    |> Igniter.compose_task("nstandard.install", [])
    |> assert_has_patch("mix.exs", " + |      package: package(),")
    |> assert_has_patch("mix.exs", " + |      licenses: [\"Apache-2.0\"],")
    |> assert_has_patch(
      "mix.exs",
      " + |      links: %{\"GitHub\" => \"https://github.com/TODO/test\"}"
    )
  end

  test "adds docs configuration" do
    test_project()
    |> Igniter.compose_task("nstandard.install", [])
    |> assert_has_patch("mix.exs", " + |      docs: docs(),")
    |> assert_has_patch("mix.exs", " + |      main: \"readme\",")
    |> assert_has_patch("mix.exs", " + |      extras: [\"README.md\"]")
  end

  test "creates changelog with initial structure" do
    test_project()
    |> Igniter.compose_task("nstandard.install", [])
    |> assert_has_patch("CHANGELOG.md", """
    1 |# Changelog
    2 |
    3 |## v0.1.0
    4 |
    5 |- TODO: write changelog
    6 |
    """)
  end
end
