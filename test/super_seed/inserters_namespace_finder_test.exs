defmodule SuperSeed.InsertersNamespaceFinderTest do
  use ExUnit.Case, async: false
  use Mimic
  import ExUnit.CaptureLog
  alias SuperSeed.InsertersNamespaceFinder
  alias SuperSeed.TestInserterNamespaces

  describe "find/0" do
    test "when the app has no config around which namespace to use, it defaults to for <app_name>.SuperSeed.Inserters" do
      logging =
        capture_log(fn ->
          assert InsertersNamespaceFinder.find() == {:ok, SuperSeed.SuperSeed.Inserters}
        end)

      assert logging =~ "[SuperSeed] Using the inserters namesapce: SuperSeed.SuperSeed.Inserters"
    end

    test "when the app is configured to use a non conventionally namespaced namespace, it gets used" do
      original_config = Application.get_env(:super_seed, :setup, [])

      test_config =
        Keyword.put(original_config, :inserters_namespace, TestInserterNamespaces.Noop)

      Application.put_env(:super_seed, :setup, test_config)

      logging =
        capture_log(fn ->
          {:ok, TestInserterNamespaces.Noop} == InsertersNamespaceFinder.find()
        end)

      assert logging =~
               "[SuperSeed] Using the inserters namespace defined in config: SuperSeed.TestInserterNamespaces.Noop"

      Application.put_env(:super_seed, :setup, original_config)
    end

    # test "if there's no :super_seed :setup :module, nor a conventionally namespaced setup module compiled, it returns an error" do
    #  Mimic.reject(&TestSetups.Simple.setup/0)
    #  Mimic.reject(&TestSetups.Simple.teardown/1)

    #  Mimic.expect(Checks, :ensure_compiled, fn module ->
    #    assert module == SuperSeed.SuperSeed.Setup
    #    false
    #  end)

    #  assert :error == SetupModuleFinder.find()
    # end
  end
end
