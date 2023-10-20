defmodule SuperSeed.ConfigReaderTest do
  use ExUnit.Case, async: true
  use Mimic
  alias SuperSeed.{Checks, ConfigReader}
  alias SuperSeed.Mocks.FakeRepo

  describe "read/0" do
    test "it reads the config" do
      Mimic.expect(Checks, :application_get_env, fn app, key ->
        assert app == :super_seed
        assert key == :setup
        [[repo_name: :cool_repo, repo: FakeRepo, app: :fake_app, app_root_namespace: CoolApp]]
      end)

      assert %{repo_name: :cool_repo, repo: FakeRepo, app: :fake_app, app_root_namespace: CoolApp} ==
               ConfigReader.read()
    end

    test "when there's no config it raises with a helpful error" do
      Mimic.expect(Checks, :application_get_env, fn _app, _key ->
        nil
      end)

      error_msg = """
      I tried to read the :setup configuration for :super_seed, but it I didn't find any.
      Maybe you skipped the step in the README about adding some config to config/config.exs?
      """

      assert_raise RuntimeError, error_msg, &ConfigReader.read/0
    end

    test "if a key is missing from the config, raise with a helpful error" do
      Mimic.expect(Checks, :application_get_env, fn _app, _key ->
        [[repo_name: :cool_repo, repo: FakeRepo, app_root_namespace: CoolApp]]
      end)

      error_msg = """
      I tried to read the :setup configuration for :super_seed, but it looks like I've been misconfigured.

      I'm missing the key: :app

      Maybe reread the README bit about adding some config?
      """

      assert_raise RuntimeError, error_msg, &ConfigReader.read/0

      Mimic.expect(Checks, :application_get_env, fn _app, _key ->
        [[repo_name: :cool_repo, app: :fake_app, app_root_namespace: CoolApp]]
      end)

      error_msg = """
      I tried to read the :setup configuration for :super_seed, but it looks like I've been misconfigured.

      I'm missing the key: :repo

      Maybe reread the README bit about adding some config?
      """

      assert_raise RuntimeError, error_msg, &ConfigReader.read/0
    end
  end
end
