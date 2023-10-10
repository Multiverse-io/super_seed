defmodule SuperSeed.TestSetups.Noop do
  @behaviour SuperSeed.Setup

  @impl true
  def setup do
    %{noop: true}
  end

  @impl true
  def teardown(%{noop: true}) do
    :ok
  end
end
