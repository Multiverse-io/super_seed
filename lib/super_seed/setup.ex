defmodule SuperSeed.SuperSeed.Setup do
  @behaviour SuperSeed.Setup
  @moduledoc """
  This module is only here as an example for how this should be used and to test that having a module
  following the convention of <app_name>.SuperSeed.Setup works with the rest of the system
  """

  @impl true
  def setup do
    %{super_seed: :minimal_test_setup}
  end

  @impl true
  def teardown(%{super_seed: :minimal_test_setup}) do
    :ok
  end
end
