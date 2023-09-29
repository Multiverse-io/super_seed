# defmodule Mix.Tasks.Gen.Seeds.Inserter do
#  @moduledoc """
#  This is used to generate a new seeds inserter module.
#
#  Usage:
#    mix gen.seeds.inserter <table_name> [<inserter_name>]
#
#  table_name: this is the main table your inserter will insert into
#
#  inserter_name: optional second argument when you want multiple inserter modules which insert into the same table
#  """
#
#  use Mix.Task
#  alias Mix.Generator
#  alias Phoenix.Naming
#
#  @shortdoc "Generates a new seeds inserter module"
#
#  def run(args) do
#    opts = parse_args(args)
#
#    file_name =
#      Path.join([
#        "test/seeds/inserters/tables",
#        Naming.underscore(opts.table_name),
#        [Naming.underscore(opts.inserter_name), ".ex"]
#      ])
#
#    contents = make_file_contents(opts)
#
#    Generator.create_file(file_name, contents)
#  end
#
#  defp parse_args([table_name, inserter_name]) do
#    %{table_name: table_name, inserter_name: inserter_name}
#  end
#
#  defp parse_args([table_name]) do
#    %{table_name: table_name, inserter_name: table_name}
#  end
#
#  defp parse_args(_) do
#    Mix.Shell.IO.error("""
#    gen.seeds.inserter expected to receive a table name and optionally an inserter name
#
#    Examples:
#      mix gen.seeds.inserter cheese
#      mix gen.seeds.inserter cheese swiss
#    """)
#
#    System.halt(1)
#  end
#
#  defp make_file_contents(opts) do
#    table_module_name = Naming.camelize(opts.table_name)
#    inserter_module_name = Naming.camelize(opts.inserter_name)
#
#    table_name = Naming.underscore(opts.table_name)
#
#    """
#    defmodule Platform.Seeds.Inserters.Tables.#{table_module_name}.#{inserter_module_name} do
#      @behaviour Platform.Seeds.Inserter
#
#      @impl true
#      def dependencies do
#        # list any dependencies here
#        # eg: [{:table, "candidates"}, {:table, "companies"}]
#        []
#      end
#
#      @impl true
#      def table, do: "#{table_name}"
#
#      @impl true
#      def insert(_previously_inserted_seed_data) do
#        # Insert some seed data here!
#      end
#    end
#    """
#  end
# end
#
