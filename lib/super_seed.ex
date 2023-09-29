defmodule SuperSeed do
  require Logger

  alias SuperSeed.Checks

  def run do
    case setup_module() do
      {:ok, module} ->
        setup_result = module.setup()
        module.teardown(setup_result)

      :error ->
        raise """
        I need a "Setup" module to run, but I couldn't find one.

        You have two options but I reccomend the first:

        1) Run `mix super_seed.init` to generate a new setup module
        2) Add some super_seed config to your config file

        Read the README for more details
        """
    end
  end

  defp setup_module do
    Enum.reduce_while(setup_module_getters(), nil, fn setup_module_getter, _acc ->
      case setup_module_getter.() do
        {:ok, module} -> {:halt, {:ok, module}}
        other -> {:cont, other}
      end
    end)
  end

  defp setup_module_getters do
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
