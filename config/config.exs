import Config

# config :super_seed, SuperSeed.ExampleRepo,
#  database: "super_seed_example_repo",
#  username: "postgres",
#  password: "postgres",
#  hostname: "localhost"
#

config :super_seed, :setup, [
  [repo_name: :example_repo, repo: SuperSeed.ExampleRepo, app: :super_seed, app_root_namespace: SuperSeed]
]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
