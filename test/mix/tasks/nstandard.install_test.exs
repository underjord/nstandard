defmodule Mix.Tasks.Nstandard.InstallTest do
  use ExUnit.Case, async: true
  import Igniter.Test

  test "project is set up according to the nerves standard practices" do
    test_project()
    |> Igniter.compose_task("nstandard.install", [])
    # Verify files are created
    |> assert_creates(".credo.exs")
    |> assert_creates(".cspell.json")
    |> assert_creates(".dialyzer_ignore.exs")
    |> assert_creates("LICENSE.md")
    |> assert_creates("CHANGELOG.md")
    # Verify dependencies are added to mix.exs
    |> assert_has_patch(
      "mix.exs",
      """
       + |      {:ex_doc, \"~> 0.40\", only: [:dev, :test], runtime: false},
       + |      {:dialyxir, \"~> 1.4\", only: [:dev, :test], runtime: false},
       + |      {:credo, \"~> 1.7\", only: [:dev, :test], runtime: false},
       + |      {:spellweaver, \"~> 0.1.8\", only: [:dev, :test], runtime: false}
      """
    )
    # Verify check alias is added
    |> assert_has_patch(
      "mix.exs",
      """
      + |      check: [
      + |        \"hex.audit\",
      + |        \"compile --warnings-as-errors --force\",
      + |        \"format --check-formatted\",
      + |        \"credo --strict\",
      + |        \"deps.unlock --check-unused\",
      + |        \"spellweaver.check\",
      + |        \"dialyzer\"
      + |      ]
      """
    )
    # Verify precommit alias is added
    |> assert_has_patch(
      "mix.exs",
      """
      + |      precommit: [
      + |        \"hex.audit\",
      + |        \"compile --warnings-as-errors --force\",
      + |        \"format\",
      + |        \"credo --strict\",
      + |        \"deps.unlock --unused\",
      + |        \"spellweaver.check\",
      + |        \"dialyzer\",
      + |        \"test\"
      + |      ]
      """
    )
    # Verify cli function is added with preferred_envs
    |> assert_has_patch("mix.exs", " + |      preferred_envs: [precommit: :test]")
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

  test "works with existing aliases function (Phoenix-style project)" do
    phx_mix_exs = """
    defmodule Test.MixProject do
      use Mix.Project

      def project do
        [
          app: :test,
          version: "0.1.0",
          elixir: "~> 1.17",
          start_permanent: Mix.env() == :prod,
          aliases: aliases(),
          deps: deps()
        ]
      end

      def cli do
        [
          preferred_envs: [precommit: :test]
        ]
      end

      def application do
        [
          extra_applications: [:logger]
        ]
      end

      defp aliases do
        [
          setup: ["deps.get", "ecto.setup"],
          precommit: ["compile --warnings-as-errors", "deps.unlock --unused", "format", "test"]
        ]
      end

      defp deps do
        [
          # {:dep_from_hexpm, "~> 0.3.0"},
        ]
      end
    end
    """

    diff =
      test_project(files: %{"mix.exs" => phx_mix_exs})
      |> Igniter.compose_task("nstandard.install", [])
      |> Igniter.Test.diff(only: "mix.exs")

    # Should add check alias into the existing defp aliases function
    assert diff =~ "check: ["
    # Should NOT create a duplicate def aliases function
    refute diff =~ "+ |  def aliases do"
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
