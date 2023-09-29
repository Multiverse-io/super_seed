defmodule SuperSeed.Checks do
  @moduledoc """
  It may seem odd to have this module,
  but it's here because it makes testing easier, because it can be mocked without doing the scary error-inducing thing of mocking the Code module
  """

  def ensure_compiled(module), do: Code.ensure_compiled(module)
end
