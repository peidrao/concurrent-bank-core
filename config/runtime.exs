import Config

if config_env() == :prod do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise "DATABASE_URL não definido. Exemplo: ecto://USER:PASS@HOST/DATABASE"

  pool_size = String.to_integer(System.get_env("DB_POOL_SIZE", "30"))

  config :bank_crud, BankCrud.Repo,
    url: database_url,
    pool_size: pool_size,
    ssl: String.downcase(System.get_env("DB_SSL", "false")) == "true"

  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise "SECRET_KEY_BASE não definido para iniciar o endpoint Phoenix"

  host = System.get_env("PHX_HOST", "localhost")
  port = String.to_integer(System.get_env("PORT", "4000"))

  config :bank_crud, BankCrudWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [ip: {0, 0, 0, 0}, port: port],
    secret_key_base: secret_key_base,
    check_origin: ["https://#{host}"]
end
