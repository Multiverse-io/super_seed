defmodule SuperSeed.Setup do
  @callback setup() :: any()
  @callback teardown(any()) :: :ok | {:error, atom}
end
