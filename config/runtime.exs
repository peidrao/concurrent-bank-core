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
end
