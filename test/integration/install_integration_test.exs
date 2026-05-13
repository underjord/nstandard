defmodule Mix.Tasks.Nstandard.InstallIntegrationTest do
  use ExUnit.Case

  # End-to-end test: shells out to `mix igniter.new --install` against this
  # checkout via a `path:` dep, then runs `mix check` on the generated project.
  # Requires the `igniter_new` archive to be installed.

  @moduletag :integration
  @moduletag timeout: :timer.minutes(15)

  @app_name "example_app"

  test "generated project passes `mix check`" do
    nstandard_path = File.cwd!()

    base =
      Path.join(
        System.tmp_dir!(),
        "nstandard_integration_#{System.unique_integer([:positive])}"
      )

    File.mkdir_p!(base)
    on_exit(fn -> File.rm_rf!(base) end)

    {igniter_output, igniter_status} =
      System.cmd(
        "mix",
        [
          "igniter.new",
          @app_name,
          "--install",
          "nstandard@path:#{nstandard_path}",
          "--yes"
        ],
        cd: base,
        stderr_to_stdout: true
      )

    assert igniter_status == 0,
           "`mix igniter.new` failed (is the `igniter_new` archive installed?):\n" <>
             igniter_output

    project_dir = Path.join(base, @app_name)

    # Replace the boilerplate module with a minimal credo-strict-passing stub.
    # Empty lib/ also breaks dialyzer (no .beam to analyze), so we need *something*.
    module_name = Macro.camelize(@app_name)

    File.write!(Path.join([project_dir, "lib", "#{@app_name}.ex"]), """
    defmodule #{module_name} do
      @moduledoc \"\"\"
      Stub module for integration testing `mix check`.
      \"\"\"

      @doc "Returns :ok."
      @spec ok() :: :ok
      def ok() do
        :ok
      end
    end
    """)

    {deps_output, deps_status} =
      System.cmd("mix", ["deps.get"], cd: project_dir, stderr_to_stdout: true)

    assert deps_status == 0, "`mix deps.get` failed:\n" <> deps_output

    {check_output, check_status} =
      System.cmd("mix", ["check"], cd: project_dir, stderr_to_stdout: true)

    assert check_status == 0, "`mix check` failed:\n" <> check_output
  end
end
