defmodule Mix.Tasks.SuperSeed.InitTest do
  use ExUnit.Case, async: true
  use Mimic
  import ExUnit.CaptureIO

  alias Mix.Tasks.SuperSeed.Init

  describe "run/1" do
    test "creates the file structure" do
      Mimic.expect(File, :exists?, fn path ->
        assert path == "lib/super_seed/setup.ex"
        false
      end)

      Mimic.expect(File, :mkdir_p!, fn path -> assert path == "lib/super_seed" end)
      Mimic.expect(File, :mkdir_p!, fn path -> assert path == "lib/super_seed/inserters" end)

      Mimic.expect(File, :write!, fn path, contents ->
        assert path == "lib/super_seed/setup.ex"

        assert contents ==
                 """
                 defmodule SuperSeed.SuperSeed.Setup do
                   @behaviour SuperSeed.Setup

                   @impl true
                   def setup do
                     # Run any pre-seeding code here
                     # For example: truncating some tables, pausing a process that's very database sensitive
                     # The return value of this function will be passed to the teardown/1 function which is run after the seed data insertion is done
                     :ok
                   end

                   @impl true
                   def teardown(_setup) do
                     # Run any post-seeding code here
                     # For example: unpausing a process that's very database sensitive
                     # The argument to this function is the return value of the setup/0 function
                     :ok
                   end
                 end
                 """
      end)

      capture_io(fn -> Init.run() end)
    end

    test "creates the setup file namespaced under the app we're actually in" do
      Mimic.expect(File, :exists?, fn path ->
        assert path == "lib/super_seed/setup.ex"
        false
      end)

      Mimic.expect(File, :mkdir_p!, fn _path -> nil end)

      Mimic.expect(File, :write!, fn path, contents ->
        assert path == "lib/super_seed/setup.ex"
        assert contents =~ "defmodule CoolDude.SuperSeed.Setup do"
      end)

      Mimic.expect(Mix.Project, :config, fn -> [app: :cool_dude] end)

      capture_io(fn -> Init.run() end)
    end

    test "exists if we can't figure out your app name my running Mix.Project.config() & prints an error on the screen" do
      Mimic.expect(Mix.Project, :config, fn -> [] end)

      Mimic.reject(File, :exists?, 1)
      Mimic.reject(File, :mkdir_p!, 1)
      Mimic.reject(File, :write!, 2)

      error = """
      I failed to run super_seed.init because I could not find the name of your app.
      I depend on being able to find the name of the app so that I can namespace the setup.ex file that I want to create correctly!

      Maybe you're not in a mix project?

      You're kind of on your own here! Sorry! Good luck!
      """

      assert_raise RuntimeError, error, fn -> Init.run() end
    end

    test "if lib/super_seed/setup.ex already exists, and has stuff in it, don't attempt to recreate it" do
      Mimic.expect(File, :exists?, fn path ->
        assert path == "lib/super_seed/setup.ex"
        true
      end)

      Mimic.expect(File, :mkdir_p!, fn path -> assert path == "lib/super_seed" end)
      Mimic.reject(File, :write!, 2)
      capture_io(fn -> Init.run() end)
    end
  end
end
