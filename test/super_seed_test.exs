defmodule SuperSeedTest do
  use ExUnit.Case, async: false
  use Mimic
  import ExUnit.CaptureLog
  alias SuperSeed.TestSetups
  alias SuperSeed.Checks

  describe "run/0" do
    test "it runs the setup, and passes the setup result to teardown, which it also runs" do
      Mimic.expect(SuperSeed.SuperSeed.Setup, :setup, fn -> :fake_setup_response end)

      Mimic.expect(SuperSeed.SuperSeed.Setup, :teardown, fn setup ->
        assert setup == :fake_setup_response
      end)

      logging = capture_log(fn -> SuperSeed.run() end)

      assert logging =~ "[SuperSeed] Using the setup module: SuperSeed.SuperSeed.Setup"
    end

    test "when the app is configured to use a non conventionally namespaced setup module, it gets run" do
      original_config = Application.get_env(:super_seed, :setup, [])
      test_config = Keyword.put(original_config, :module, TestSetups.Noop)
      Application.put_env(:super_seed, :setup, test_config)

      Mimic.reject(&SuperSeed.SuperSeed.Setup.setup/0)
      Mimic.reject(&SuperSeed.SuperSeed.Setup.teardown/1)

      logging = capture_log(fn -> SuperSeed.run() end)

      assert logging =~
               "[SuperSeed] Using the setup module defined in config: SuperSeed.TestSetups.Noop"

      Application.put_env(:super_seed, :setup, original_config)
    end

    test "if there's no :super_seed :setup :module, nor a conventionally namespaced setup module, it raises" do
      Mimic.reject(&SuperSeed.SuperSeed.Setup.setup/0)
      Mimic.reject(&SuperSeed.SuperSeed.Setup.teardown/1)

      Mimic.expect(Checks, :ensure_compiled, fn module ->
        assert module == SuperSeed.SuperSeed.Setup
        false
      end)

      error_msg = """
      I need a "Setup" module to run, but I couldn't find one.

      You have two options but I reccomend the first:

      1) Run `mix super_seed.init` to generate a new setup module
      2) Add some super_seed config to your config file

      Read the README for more details
      """

      assert_raise RuntimeError, error_msg, fn -> SuperSeed.run() end
    end
  end
end
