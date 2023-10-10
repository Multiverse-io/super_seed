defmodule SuperSeed.ApplicationRootNamespace do
  def determine_from_mix_project do
    Mix.Project.config()
    |> Keyword.get(:app)
    |> case do
      nil ->
        raise """
        I could not find the name of your app by running Mix.Project.config() and looking for the :app key.
        I depend on being able to find the name of the app so that I can namespace generated files correctly!

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
