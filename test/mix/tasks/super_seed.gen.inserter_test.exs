defmodule Mix.Tasks.SuperSeed.Gen.InserterTest do
  use ExUnit.Case, async: true
  use Mimic
  import ExUnit.CaptureIO
  alias Mix.Tasks.SuperSeed.Gen.Inserter

  describe "run/1" do
    test "given the minimum valid args, generates a new inserter file" do
      Mimic.expect(File, :write!, fn path, contents ->
        assert path == "lib/super_seed/inserters/tables/users/users.ex"

        assert contents ==
                 """
                 defmodule SuperSeed.SuperSeed.Inserters.Tables.Users.Users do
                  @behaviour SuperSeed.Inserter

                  @impl true
                  def dependencies do
                    # list any dependencies here
                    # eg: [{:table, "candidates"}, {:table, "companies"}]
                    []
                  end

                  @impl true
                  def table, do: "users"

                  @impl true
                  def insert(_previously_inserted_seed_data) do
                    # Insert some seed data here!
                  end
                 end
                 """
      end)

      Mimic.expect(File, :mkdir_p!, fn _path -> nil end)

      # Inserter.run(["users"])
      capture_io(fn -> Inserter.run(["users"]) end)
    end

    test "missing directories are created for the new inserter" do
      Mimic.expect(File, :write!, fn _path, _contents -> true end)

      Mimic.expect(File, :mkdir_p!, fn path ->
        assert path == "lib/super_seed/inserters/tables/users"
      end)

      # Inserter.run(["users"])
      capture_io(fn -> Inserter.run(["users"]) end)
    end

    test "given a table_name and inserter_name, generates the expected file contents" do
      Mimic.expect(File, :write!, fn path, contents ->
        assert path == "lib/super_seed/inserters/tables/cheesy_table_name/yorkshire_cheddar.ex"

        assert contents ==
                 """
                 defmodule SuperSeed.SuperSeed.Inserters.Tables.CheesyTableName.YorkshireCheddar do
                  @behaviour SuperSeed.Inserter

                  @impl true
                  def dependencies do
                    # list any dependencies here
                    # eg: [{:table, "candidates"}, {:table, "companies"}]
                    []
                  end

                  @impl true
                  def table, do: "cheesy_table_name"

                  @impl true
                  def insert(_previously_inserted_seed_data) do
                    # Insert some seed data here!
                  end
                 end
                 """
      end)

      Mimic.expect(File, :mkdir_p!, fn path ->
        assert path == "lib/super_seed/inserters/tables/cheesy_table_name"
      end)

      # Inserter.run(["users"])
      capture_io(fn -> Inserter.run(["cheesy_table_name", "yorkshire_cheddar"]) end)
    end

    test "given bad args, prints an error message and exits" do
      Mimic.expect(System, :halt, fn _code -> :ok end)
      Mimic.reject(&File.write!/2)
      Mimic.reject(&File.mkdir_p!/1)

      # Inserter.run([])
      captured = capture_io(:stderr, fn -> Inserter.run([]) end)

      assert captured ==
               """
               mix super_seed.gen.inserter expected to receive a table name and optionally an inserter name

               Examples:
                 mix super_seed.gen.inserter cheese
                 mix super_seed.gen.inserter cheese swiss

               """
    end

    test "when the mix projects app name cannot be determined, we raise with a message" do
      Mimic.expect(Mix.Project, :config, fn -> [] end)
      Mimic.reject(&File.write!/2)
      Mimic.reject(&File.mkdir_p!/1)

      error_msg = """
      I failed to run because I could not find the name of your app.
      I depend on being able to find the name of the app so that I can namespace the SuperSeed.Inserter file that I want to create correctly!

      Maybe you're not in a mix project?

      You're kind of on your own here! Sorry! Good luck!
      """

      assert_raise RuntimeError, error_msg, fn -> Inserter.run(["users"]) end
    end
  end
end
