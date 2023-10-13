defmodule SuperSeed.Inserter do
  @callback dependencies() :: [{:atom, String.t()}]
  @callback table() :: String.t()
  @callback insert(any()) :: any()
end
