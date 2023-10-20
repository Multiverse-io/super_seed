# SuperSeed

A tool for parallelising seed data insertion into a database with Ecto.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `super_seed` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:super_seed, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/super_seed>.

Next, in `config/config.exs`, add:

```elixir
config :super_seed, :setup, [
  [repo_name: :my_repo, repo: SuperSeed.Repo, app: :super_seed, app_root_namespace: SuperSeed]
]
```

and now set all of the options:

- `:name` is used to identify which repo we're talking about, and is used in the directory structure some generators we'll create later
- `:repo` must be the module name of the `Ecto` `Repo` for which we'll insert seed data into
- `:app` must be set to the same thing as `:app` in `project/0` in your `mix.exs` file
- `:app_root_namespace` must be top-level module in your app. This is used later to put generators into the correct namespace.


Note that the config under `:setup` is indeed a list of lists (the extra `[]` is not a typo!).
Each item in the list is a setup for a given repo. Multiple setups for different repos may be added, but we won't worry about that for now and just focus on setting up one.

Next run `mix super_seed.init`



