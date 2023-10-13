defmodule SuperSeed.InsertersNamespaceFinder do
  require Logger

  def find do
    Enum.reduce_while(finders(), nil, fn finder, _acc ->
      case finder.() do
        {:ok, module} -> {:halt, {:ok, module}}
        other -> {:cont, other}
      end
    end)
  end

  defp finders do
    [&from_config/0, &default/0]
  end

  defp from_config do
    module =
      :super_seed
      |> Application.get_env(:setup, [])
      |> Keyword.get(:inserters_namespace)

    if module do
      Logger.info(
        "[SuperSeed] Using the inserters namespace defined in config: #{inspect(module)}"
      )

      {:ok, module}
    else
      :error
    end
  end

  defp default do
    app_module =
      Mix.Project.config()
      |> Keyword.get(:app)
      |> to_string()
      |> Macro.camelize()

    namespace = :"Elixir.#{app_module}.SuperSeed.Inserters"
    Logger.info("[SuperSeed] Using the inserters namesapce: #{inspect(namespace)}")

    {:ok, namespace}
  end
end
