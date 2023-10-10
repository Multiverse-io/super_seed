defmodule SuperSeed.ApplicationRootNamespaceTest do
  use ExUnit.Case, async: true

  describe "determine_from_mix_project/0" do
    test "given a mix project with an app name, returns the app name in upper camel case" do
      Mimic.expect(Mix.Project, :config, fn -> [app: :my_app] end)

      assert SuperSeed.ApplicationRootNamespace.determine_from_mix_project() == "MyApp"
    end

    test "given not finding a mix project with an app name, raises" do
      Mimic.expect(Mix.Project, :config, fn -> [] end)

      error_msg = """
      I could not find the name of your app by running Mix.Project.config() and looking for the :app key.
      I depend on being able to find the name of the app so that I can namespace generated files correctly!

      Maybe you're not in a mix project?

      You're kind of on your own here! Sorry! Good luck!
      """

      assert_raise RuntimeError,
                   error_msg,
                   &SuperSeed.ApplicationRootNamespace.determine_from_mix_project/0
    end
  end
end
