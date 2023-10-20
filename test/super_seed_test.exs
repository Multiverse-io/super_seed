defmodule SuperSeedTest do
  use ExUnit.Case, async: false
  use Mimic
  import ExUnit.CaptureLog
  alias SuperSeed.{InsertersNamespaceFinder, Mocks, SetupModuleFinder, TestSetups}
  alias SuperSeed.TestInserterNamespaces.Simple.Tables.{Dogs, DogWalking, Mammals}

  describe "run/0" do
    test "it runs the setup, and passes the setup result to teardown, which it also runs" do
      Mimic.stub_with(SetupModuleFinder, Mocks.FakeSetupModuleFinder)
      Mimic.stub_with(InsertersNamespaceFinder, Mocks.FakeInserterModuleFinder)

      Mimic.expect(TestSetups.Simple, :setup, 1, fn -> :fake_setup_response end)

      Mimic.expect(TestSetups.Simple, :teardown, fn setup ->
        assert setup == :fake_setup_response
      end)

      # Mammals.output_when_run()
      # Dogs.output_when_run()
      # DogWalking.output_when_run()
      Code.ensure_loaded?(Mammals)
      |> IO.inspect()

      # Code.required_files()
      # |> IO.inspect()

      # Code.compiler_options()
      # |> IO.inspect()

      capture_log(fn -> assert :ok == SuperSeed.run() end)
    end

    test "it runs the inserters under the inserter namespace it's configured to use" do
      Mimic.stub_with(SetupModuleFinder, Mocks.FakeSetupModuleFinder)
      Mimic.stub_with(InsertersNamespaceFinder, Mocks.FakeInserterModuleFinder)

      logging = capture_log(fn -> assert :ok == SuperSeed.run() end)

      assert logging =~ Mammals.output_when_run()
      assert logging =~ Dogs.output_when_run()
      assert logging =~ DogWalking.output_when_run()
    end
  end
end
