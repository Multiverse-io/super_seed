defmodule SuperSeed.TestInserterNamespaces.Noop.Tables.TheOneAndOnlyNoop do
  @behaviour SuperSeed.Inserter

  @impl true
  def dependencies do
    []
  end

  @impl true
  def table, do: "noop"

  @impl true
  def insert(_previously_inserted_seed_data) do
    :ok
  end
end
