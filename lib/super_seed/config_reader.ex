defmodule SuperSeed.ConfigReader do
  alias SuperSeed.Checks

  @setup_keys [:repo_name, :repo, :app, :app_root_namespace]

  def read do
    :super_seed
    |> Checks.application_get_env(:setup)
    |> parse()
  end

  defp parse([setup | _]) do
    Enum.reduce(@setup_keys, %{}, fn key, acc ->
      case Keyword.get(setup, key) do
        nil ->
          raise """
          I tried to read the :setup configuration for :super_seed, but it looks like I've been misconfigured.

          I'm missing the key: #{inspect(key)}

          Maybe you reread the README bit about adding some config?
          """

        value ->
          Map.put(acc, key, value)
      end
    end)
  end

  defp parse(_) do
    raise """
    I tried to read the :setup configuration for :super_seed, but it I didn't find any.
    Maybe you skipped the step in the README about adding some config to config/config.exs?
    """
  end
end
