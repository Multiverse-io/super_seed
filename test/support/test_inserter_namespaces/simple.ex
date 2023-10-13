defmodule SuperSeed.TestInserterNamespaces.Simple.Tables.Mammals do
  @behaviour SuperSeed.Inserter

  @impl true
  def dependencies do
    []
  end

  @impl true
  def table, do: "mammals"

  @impl true
  def insert(_previously_inserted_seed_data) do
    output = output_when_run()
    IO.puts(output)
    output
  end

  def output_when_run do
    "I love mammals!"
  end
end

defmodule SuperSeed.TestInserterNamespaces.Simple.Tables.Dogs do
  @behaviour SuperSeed.Inserter

  @impl true
  def dependencies do
    [{:table, "mammals"}]
  end

  @impl true
  def table, do: "dogs"

  @impl true
  def insert(_previously_inserted_seed_data) do
    output = output_when_run()
    IO.puts(output)
    output
  end

  def output_when_run do
    "I'm into dogs don't you know"
  end
end

defmodule SuperSeed.TestInserterNamespaces.Simple.Tables.DogWalking do
  @behaviour SuperSeed.Inserter

  @impl true
  def dependencies do
    [{:table, "dogs"}]
  end

  @impl true
  def table, do: "dog_walking"

  @impl true
  def insert(_previously_inserted_seed_data) do
    output = output_when_run()
    IO.puts(output)
    output
  end

  def output_when_run do
    "you need dogs to walk 'em don't ya"
  end
end
