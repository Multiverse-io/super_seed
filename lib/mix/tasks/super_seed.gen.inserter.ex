defmodule Mix.Tasks.SuperSeed.Gen.Inserter do
  use Mix.Task
  alias Mix.Generator

  # def run([table_name]) do
  def run(args) do
    case parse_args(args) do
      {table_name, inserter_name} ->
        file_name =
          Path.join(["lib/super_seed/inserters/tables", table_name, "#{inserter_name}.ex"])

        contents = make_file_contents(table_name, inserter_name)
        Generator.create_file(file_name, contents)

      :error ->
        System.halt(1)
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

    """
    defmodule #{app_module()}.SuperSeed.Inserters.Tables.#{camelised_table_name}.#{camelised_inserter_name} do
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

  defp app_module do
    Mix.Project.config()
    |> Keyword.get(:app)
    |> case do
      nil ->
        raise """
        I failed to run because I could not find the name of your app.
        I depend on being able to find the name of the app so that I can namespace the SuperSeed.Inserter file that I want to create correctly!

        Maybe you're not in a mix project?

        You're kind of on your own here! Sorry! Good luck!
        """

      app ->
        app
        |> to_string()
        |> Macro.camelize()
    end
  end
end
