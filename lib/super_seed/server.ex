defmodule SuperSeed.Server do
  @moduledoc """
  For a partial explanation of how this works, see test/seeds/inserter.ex

  It explains the behaviour of the inserter modules, which this module is responsible for inserting into the database in separate transactions.
  """

  use GenServer
  require Logger

  # alias Platform.Seeds.{PlatformModules, TransactionRunner}
  alias SuperSeed.TransactionRunner

  @tables "Tables"
  @collections "Collections"
  @inserter_types [@tables, @collections]

  def start_link(parent_pid, inserters, opts \\ []) do
    GenServer.start_link(__MODULE__, {parent_pid, inserters, opts}, name: __MODULE__)
  end

  @impl true
  def init({parent_pid, inserters, opts}) do
    IO.inspect(inserters)
    raise "no"
    # timeout = Keyword.get(opts, :timeout, 480_000)
    # %{tables: tables, inserters: inserters} = parse_inserters()
    # inserters = initialise_transaction_runners(inserters, timeout)

    # {:ok, %{tables: tables, inserters: inserters, results: %{}, parent_pid: parent_pid},
    # {:continue, :start}}
  end

  @impl true
  def handle_continue(:start, state) do
    state
    |> run_available_inserters()
    |> finished_if_all_inserters_finished()
  end

  @impl true
  def handle_cast({:inserter_finished, inserter_pid, result}, state) do
    state
    |> inserter_finished(inserter_pid, result)
    |> run_available_inserters()
    |> finished_if_all_inserters_finished()
  end

  @impl true
  def terminate(:normal, state) do
    send(state.parent_pid, :server_done)
  end

  defp inserter_finished(state, inserter_pid, result) do
    %{module: module} = Map.fetch!(state.inserters, inserter_pid)

    state
    |> put_in([:results, module], result)
    |> put_in([:inserters, inserter_pid, :status], :finished)
  end

  defp parse_inserters do
    {:ok, modules} = PlatformModules.all()

    modules
    |> Enum.reduce(%{tables: %{}, inserters: []}, fn module, acc ->
      case Module.split(module) do
        ["Platform", "Seeds", "Inserters", type | _] when type in @inserter_types ->
          inserter = parse_inserter(module)

          tables =
            Enum.reduce(inserter.tables, acc.tables, fn table, acc ->
              Map.update(acc, table, [inserter.module], fn modules ->
                [inserter.module | modules]
              end)
            end)

          %{acc | tables: tables, inserters: [inserter | acc.inserters]}

        _ ->
          acc
      end
    end)
  end

  # TODO deal with this?
  # @doc """
  # This function exists only as a diagnostic tool.
  # It finds all "Inserter" modules & maps their dependencies to one another, either by :table or by :module.

  # We've found this to be a helpful thing to look at when adding / editing seed data "Inserters".

  # Run it within iex by doing...

  # ```
  # iex -S mix
  # Platform.Seeds.Server.inserter_dependencies()
  # ```

  # see test/seeds/seed_server_test.exs for a clear example of how this works

  # but basically it returns:
  # %{
  #  tables: %{"table_name" => list_of_inserter_modules_that_depend_on_all_inserters_for_table_name_to_be_finished_first},
  #  modules: %{InserterModuleName => list_of_inserter_modules_that_depend_on_InserterModuleName_being_finished_first}
  # }

  # """
  # def inserter_dependencies do
  #  {:ok, modules} = PlatformModules.all()

  #  modules
  #  |> Enum.reduce(%{tables: %{}, modules: %{}}, fn module, acc ->
  #    case Module.split(module) do
  #      ["Platform", "Seeds", "Inserters", type | _] when type in @inserter_types ->
  #        dependencies = module.dependencies()

  #        Enum.reduce(dependencies, acc, fn
  #          {:table, table}, inner_acc ->
  #            update_in(inner_acc, [:tables, table], fn
  #              nil -> [module]
  #              modules -> [module | modules]
  #            end)

  #          {:module, dep_module}, inner_acc ->
  #            update_in(inner_acc, [:modules, dep_module], fn
  #              nil -> [module]
  #              modules -> [module | modules]
  #            end)
  #        end)

  #      _ ->
  #        acc
  #    end
  #  end)
  # end

  defp initialise_transaction_runners(inserters, timeout) do
    Map.new(inserters, fn inserter ->
      module = inserter.module
      {:ok, inserter_pid} = TransactionRunner.start_link(self(), module, timeout)
      {inserter_pid, Map.put(inserter, :status, :pending)}
    end)
  end

  defp parse_inserter(module) do
    %{
      tables: parse_tables(module.table()),
      dependencies: module.dependencies(),
      module: module
    }
  end

  defp parse_tables(tables) when is_list(tables) do
    tables
  end

  defp parse_tables(table) when is_binary(table) do
    [table]
  end

  defp run_available_inserters(state) do
    inserters =
      Map.new(state.inserters, fn {inserter_pid, inserter} ->
        if can_run?(inserter, state.inserters, state.tables) do
          GenServer.cast(inserter_pid, {:run, state.results})
          {inserter_pid, Map.put(inserter, :status, :running)}
        else
          {inserter_pid, inserter}
        end
      end)

    %{state | inserters: inserters}
  end

  defp can_run?(%{status: :pending, dependencies: dependencies}, inserters, tables) do
    inserter_modules =
      Map.new(inserters, fn {_module_pid, inserter} -> Map.pop!(inserter, :module) end)

    Enum.all?(dependencies, fn
      {:module, dependency} ->
        inserter_modules[dependency][:status] == :finished

      {:table, table} ->
        tables
        |> Map.fetch!(table)
        |> Enum.all?(fn dependency -> inserter_modules[dependency][:status] == :finished end)
    end)
  end

  defp can_run?(_inserter, _inserters, _tables) do
    false
  end

  defp finished_if_all_inserters_finished(state) do
    statuses =
      Enum.reduce(state.inserters, %{}, fn {_, %{module: module, status: status}}, acc ->
        Map.update(acc, status, [module], fn modules -> [module | modules] end)
      end)

    Enum.each(statuses, fn {status, modules} ->
      Logger.debug("Server Inserters #{status}: #{Enum.join(modules, ", ")}")
    end)

    if Enum.all?(state.inserters, fn {_, %{status: status}} -> status == :finished end) do
      {:stop, :normal, state}
    else
      {:noreply, state}
    end
  end
end
