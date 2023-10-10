defmodule Mix.Tasks.SuperSeed.Gen.Inserter do
  use Mix.Task
  alias Mix.Generator
  alias SuperSeed.{ApplicationRootNamespace, SystemHalt}

  def run(args) do
    case parse_args(args) do
      {table_name, inserter_name} ->
        file_name =
          Path.join(["lib/super_seed/inserters/tables", table_name, "#{inserter_name}.ex"])

        contents = make_file_contents(table_name, inserter_name)
        Generator.create_file(file_name, contents)

      :error ->
        SystemHalt.halt(1)
    end
  end

  defp parse_args([table_name, inserter_name]) do
    {table_name, inserter_name}
  end

  defp parse_args([table_name]) do
    {table_name, table_name}
  end

  defp parse_args(_) do
    Mix.Shell.IO.error("""
    mix super_seed.gen.inserter expected to receive a table name and optionally an inserter name

    Examples:
      mix super_seed.gen.inserter cheese
      mix super_seed.gen.inserter cheese swiss
    """)

    :error
  end

  defp make_file_contents(table_name, inserter_name) do
    camelised_table_name = Macro.camelize(table_name)
    camelised_inserter_name = Macro.camelize(inserter_name)
    app_module = ApplicationRootNamespace.determine_from_mix_project()

    """
    defmodule #{app_module}.SuperSeed.Inserters.Tables.#{camelised_table_name}.#{camelised_inserter_name} do
     @behaviour SuperSeed.Inserter

     @impl true
     def dependencies do
       # list any dependencies here
       # eg: [{:table, "candidates"}, {:table, "companies"}]
       []
     end

     @impl true
     def table, do: "#{table_name}"

     @impl true
     def insert(_previously_inserted_seed_data) do
       # Insert some seed data here!
     end
    end
    """
  end
end
