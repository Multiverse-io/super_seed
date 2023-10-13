defmodule SuperSeed.Mocks.FakeSetupModuleFinder do
  alias SuperSeed.TestSetups.Simple

  def find, do: {:ok, Simple}
end
