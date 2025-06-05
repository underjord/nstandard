defmodule Mix.Tasks.Nstandard.InstallTest do
  use ExUnit.Case, async: true
  import Igniter.Test

  test "project is set up according to the nerves standard practices" do
    test_project()
    |> Igniter.compose_task("nstandard.install", [])
    # Verify files are created
    |> assert_creates(".credo.exs")
    |> assert_creates("LICENSE.md")
    |> assert_creates("CHANGELOG.md")
    # Verify dependencies are added to mix.exs
    |> assert_has_patch(
      "mix.exs",
      "        55 + |      {:ex_doc, \"~> 0.31\", only: [:dev, :test]},"
    )
    |> assert_has_patch(
      "mix.exs",
      "        56 + |      {:dialyxir, \"~> 1.0\", only: [:dev, :test]},"
    )
    |> assert_has_patch(
      "mix.exs",
      "        57 + |      {:credo, \"~> 1.7\", only: [:dev, :test]}"
    )
    # Verify aliases are added
    |> assert_has_patch("mix.exs", "        43 + |      check: [")
    |> assert_has_patch(
      "mix.exs",
      "        44 + |        \"compile --warnings-as-errors --force\","
    )
    |> assert_has_patch("mix.exs", "        45 + |        \"format --check-formatted\",")
    |> assert_has_patch("mix.exs", "        46 + |        \"credo\",")
    |> assert_has_patch("mix.exs", "        47 + |        \"dialyzer\"")
  end

  test "adds proper credo configuration" do
    test_project()
    |> Igniter.compose_task("nstandard.install", [])
    |> assert_has_patch(".credo.exs", "     8  |      strict: true,")
    |> assert_has_patch(".credo.exs", "    10 |        {Credo.Check.Refactor.MapInto, false},")
    |> assert_has_patch(".credo.exs", "    11 |        {Credo.Check.Warning.LazyLogging, false},")
  end

  test "adds package configuration with proper links and license" do
    test_project()
    |> Igniter.compose_task("nstandard.install", [])
    |> assert_has_patch("mix.exs", "        14 + |      package: package(),")
    |> assert_has_patch("mix.exs", "        36 + |      licenses: [\"Apache-2.0\"],")
    |> assert_has_patch(
      "mix.exs",
      "        37 + |      links: %{\"GitHub\" => \"https://github.com/TODO/test\"}"
    )
  end

  test "adds docs configuration" do
    test_project()
    |> Igniter.compose_task("nstandard.install", [])
    |> assert_has_patch("mix.exs", "        13 + |      docs: docs(),")
    |> assert_has_patch("mix.exs", "        28 + |      main: \"readme\",")
    |> assert_has_patch("mix.exs", "        29 + |      extras: [\"README.md\"]")
  end

  test "creates changelog with initial structure" do
    test_project()
    |> Igniter.compose_task("nstandard.install", [])
    |> assert_has_patch("CHANGELOG.md", "     1 |# Changelog")
    |> assert_has_patch("CHANGELOG.md", "     3 |## v0.1.0")
    |> assert_has_patch("CHANGELOG.md", "     5 |- TODO: write changelog")
  end
end
