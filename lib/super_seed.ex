defmodule SuperSeed do
  require Logger
  alias SuperSeed.{SetupModuleFinder, InsertersNamespaceFinder, InserterModules}

  def run do
    %{inserters_namespace: inserters_namespace, setup_module: setup_module} = setup()
    setup_result = setup_module.setup()
    {:ok, _server_pid} = Server.start_link(self(), inserters_namespace)

    timeout = 480_000

    receive do
      :server_done ->
        # Logger.debug("#{inspect(__MODULE__)} recieved :server_done")
        :ok
    after
      timeout ->
        raise "Reseeding the database timed out after #{timeout}ms"
    end

    setup_module.teardown(setup_result)
    :ok
  end

  defp setup do
    Enum.reduce_while(setup_functions(), %{}, fn {key, setup_fun, error_msg}, acc ->
      case setup_fun.() do
        {:ok, result} ->
          {:cont, Map.put(acc, key, result)}

        _ ->
          {:halt, raise(error_msg)}
      end
    end)
  end

  defp setup_functions do
    [
      {:setup_module, &SetupModuleFinder.find/0, setup_module_error_msg()},
      {:inserters_namespace, &InsertersNamespaceFinder.find/0, "some error"}
    ]
  end

  defp setup_module_error_msg do
    """
    I need a "Setup" module to run, but I couldn't find one.

    You have two options but I reccomend the first:

    1) Run `mix super_seed.init` to generate a new setup module
    2) Add some super_seed config to your config file

    Read the README for more details
    """
  end
end
