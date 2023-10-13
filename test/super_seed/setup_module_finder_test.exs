defmodule SuperSeed.SetupModuleFinderTest do
  use ExUnit.Case, async: false
  use Mimic
  import ExUnit.CaptureLog
  alias SuperSeed.{Checks, SetupModuleFinder, TestSetups}

  describe "find/0" do
    test "when the app has no config around which module to use, it looks for <app_name>.SuperSeed.Setup and checks if it's compiled" do
      Mimic.expect(Checks, :ensure_compiled, fn _module -> true end)

      capture_log(fn -> assert {:ok, SuperSeed.SuperSeed.Setup} == SetupModuleFinder.find() end)
    end

    test "when the app is configured to use a non conventionally namespaced setup module, it gets used" do
      original_config = Application.get_env(:super_seed, :setup, [])
      test_config = Keyword.put(original_config, :module, TestSetups.Noop)
      Application.put_env(:super_seed, :setup, test_config)

      logging = capture_log(fn -> {:ok, TestSetups.Noop} == SetupModuleFinder.find() end)

      assert logging =~
               "[SuperSeed] Using the setup module defined in config: SuperSeed.TestSetups.Noop"

      Application.put_env(:super_seed, :setup, original_config)
    end

    test "if there's no :super_seed :setup :module, nor a conventionally namespaced setup module compiled, it returns an error" do
      Mimic.reject(&TestSetups.Simple.setup/0)
      Mimic.reject(&TestSetups.Simple.teardown/1)

      Mimic.expect(Checks, :ensure_compiled, fn module ->
        assert module == SuperSeed.SuperSeed.Setup
        false
      end)

      assert :error == SetupModuleFinder.find()
    end
  end
end
