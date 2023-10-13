defmodule SuperSeed.SetupModuleFinder do
  require Logger
  alias SuperSeed.Checks

  def find do
    Enum.reduce_while(finders(), nil, fn setup_module_getter, _acc ->
      case setup_module_getter.() do
        {:ok, module} -> {:halt, {:ok, module}}
        other -> {:cont, other}
      end
    end)
  end

  defp finders do
    [&config_setup_module/0, &default_setup_module/0]
  end

  defp config_setup_module do
    module =
      :super_seed
      |> Application.get_env(:setup, [])
      |> Keyword.get(:module)

    if module do
      Logger.info("[SuperSeed] Using the setup module defined in config: #{inspect(module)}")
      {:ok, module}
    else
      :error
    end
  end

  defp default_setup_module do
    app_module =
      Mix.Project.config()
      |> Keyword.get(:app)
      |> to_string()
      |> Macro.camelize()

    module = :"Elixir.#{app_module}.SuperSeed.Setup"

    if Checks.ensure_compiled(module) do
      Logger.info("[SuperSeed] Using the setup module: #{inspect(module)}")
      {:ok, module}
    else
      :error
    end
  end
end
