use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :scamdb, ScamdbWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :scamdb, Scamdb.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "rogon",
  password: "rogon",
  database: "scamdb_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
