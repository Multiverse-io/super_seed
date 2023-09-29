defmodule Mix.Tasks.SuperSeed.Init do
  use Mix.Task
  require Mix.Generator

  def run(_args \\ []) do
    app_module = app_module()
    Mix.Generator.create_directory("lib/super_seed")
    Mix.Generator.create_directory("lib/super_seed/inserters")

    if File.exists?("lib/super_seed/setup.ex") do
      log(:yellow, :already_exists, "lib/super_seed/setup.ex")
    else
      log(:green, :creating, "lib/super_seed/setup.ex")
      File.write!("lib/super_seed/setup.ex", setup_file_contents(app_module))
    end
  end

  defp log(colour, command, message) do
    Mix.shell().info([colour, "* #{command} ", :reset, message])
  end

  # TODO this app getting but also turning app to camelised thing is duplicated around. remove the duplication
  defp app_module do
    Mix.Project.config()
    |> Keyword.get(:app)
    |> case do
      nil ->
        raise """
        I failed to run super_seed.init because I could not find the name of your app.
        I depend on being able to find the name of the app so that I can namespace the setup.ex file that I want to create correctly!

        Maybe you're not in a mix project?

        You're kind of on your own here! Sorry! Good luck!
        """

      app ->
        app
        |> to_string()
        |> Macro.camelize()
    end
  end

  defp setup_file_contents(app_module) do
    """
    defmodule #{app_module}.SuperSeed.Setup do
      @behaviour SuperSeed.Setup

      @impl true
      def setup do
        # Run any pre-seeding code here
        # For example: truncating some tables, pausing a process that's very database sensitive
        # The return value of this function will be passed to the teardown/1 function which is run after the seed data insertion is done
        :ok
      end

      @impl true
      def teardown(_setup) do
        # Run any post-seeding code here
        # For example: unpausing a process that's very database sensitive
        # The argument to this function is the return value of the setup/0 function
        :ok
      end
    end
    """
  end
end
