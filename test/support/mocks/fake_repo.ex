defmodule SuperSeed.Mocks.FakeRepo do
  def transaction(fun) do
    fun.()
  end
end
