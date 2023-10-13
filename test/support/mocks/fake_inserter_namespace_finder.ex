defmodule SuperSeed.Mocks.FakeInserterModuleFinder do
  alias SuperSeed.TestInserterNamespaces.Simple

  def find, do: {:ok, Simple}
end
