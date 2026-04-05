import Config

config :bank_crud, BankCrud.Repo,
  username: System.get_env("DB_USER", "postgres"),
  password: System.get_env("DB_PASSWORD", "postgres"),
  hostname: System.get_env("DB_HOST", "localhost"),
  database: System.get_env("DB_NAME_TEST", "bank_crud_test"),
  port: String.to_integer(System.get_env("DB_PORT", "5434")),
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

config :bank_crud, BankCrudWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "test_secret_key_base_test_secret_key_base_test_secret_key_base",
  server: false,
  check_origin: false
