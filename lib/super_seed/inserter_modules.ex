defmodule SuperSeed.InserterModules do
  alias SuperSeed.Checks

  def find(namespace) do
    namespace =
      to_string(namespace)
      |> IO.inspect()

    Checks.code_all_loaded()
    # |> Enum.filter(fn {module, _} ->
    #  # IO.inspect(to_string(module))
    #  String.starts_with?(to_string(module), "Elixir.SuperSeed")
    #  # raise "no"
    # end)
    # |> IO.inspect(limit: :infinity)
    |> Enum.reduce([], fn {module, _}, acc ->
      module_string = to_string(module)

      if String.starts_with?(module_string, namespace) do
        [module | acc]
      else
        acc
      end
    end)
    |> Enum.reverse()
  end
end
