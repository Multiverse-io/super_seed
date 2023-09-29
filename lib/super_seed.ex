defmodule SuperSeed do
  require Logger

  def run do
    setup_module = setup_module()

    setup_result = setup_module.setup()
    setup_module.teardown(setup_result)
  end

  defp setup_module do
    Enum.reduce_while(setup_module_getters(), nil, fn setup_module_getter, _acc ->
      case setup_module_getter.() do
        nil -> {:cont, nil}
        {:ok, module} -> {:halt, module}
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
      nil
    end
  end

  defp default_setup_module do
    app_module =
      Mix.Project.config()
      |> Keyword.get(:app)
      |> to_string()
      |> Macro.camelize()

    module = :"Elixir.#{app_module}.SuperSeed.Setup"

    # its very hard (impossible?) to test the else clause of this if statement, so it's untested, so careful changing this
    if Code.ensure_compiled(module) do
      Logger.info("[SuperSeed] Using the setup module: #{inspect(module)}")
      {:ok, module}
    else
      raise """
        I need a "Setup" module to run, but I couldn't find one.

        You have two options but I reccomend the first:

        1) I suggest you run `mix super_seed.init` to generate a new setup module
        2) Add some super_seed config to your config file

        Read the README for more details
      """
    end
  end
end
