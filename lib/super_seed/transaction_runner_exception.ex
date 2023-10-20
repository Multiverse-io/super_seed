defmodule SuperSeed.TransactionRunnerException do
  defexception [:message]

  @impl true
  def exception(value) do
    msg = "A Seed TransactionRunner exited for an unexpected reason, got: #{inspect(value)}"
    %__MODULE__{message: msg}
  end
end
