defmodule SuperSeed.SystemHalt do
  @moduledoc """
  It may seem odd to have this module,
  but it's here because it makes testing easier, because it can be mocked without doing the scary error-inducing thing of mocking the System module
  """

  def halt(exit_code), do: System.halt(exit_code)
end
