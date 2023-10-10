import Config

# config :super_seed, SuperSeed.ExampleRepo,
#  database: "super_seed_example_repo",
#  username: "postgres",
#  password: "postgres",
#  hostname: "localhost"
#
# config :super_seed, ecto_repos: [SuperSeed.ExampleRepo]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
