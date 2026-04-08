import Config

config :bank_crud, BankCrud.Repo,
  username: System.get_env("DB_USER", "postgres"),
  password: System.get_env("DB_PASSWORD", "postgres"),
  hostname: System.get_env("DB_HOST", "localhost"),
  database: System.get_env("DB_NAME", "bank_crud_dev"),
  port: String.to_integer(System.get_env("DB_PORT", "5434")),
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: String.to_integer(System.get_env("DB_POOL_SIZE", "30"))

config :bank_crud, BankCrudWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: String.to_integer(System.get_env("PORT", "4000"))],
  secret_key_base: System.get_env("SECRET_KEY_BASE")

config :bank_crud, AuthMe.UserManager.Guardian,
  issuer: "bank_crud",
  secret_key: System.get_env("JWT_SECRET"),
  check_origin: false,
  debug_errors: true,
  code_reloader: false
