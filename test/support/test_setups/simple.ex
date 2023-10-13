defmodule SuperSeed.TestSetups.Simple do
  @behaviour SuperSeed.Setup

  @impl true
  def setup do
    %{super_seed: :minimal_test_setup}
  end

  @impl true
  def teardown(%{super_seed: :minimal_test_setup}) do
    :ok
  end
end
