import Config

config :bank_crud,
  ecto_repos: [BankCrud.Repo]

config :bank_crud, BankCrudWeb.Endpoint, url: [host: "localhost"]

config :bank_crud, BankCrud.Repo,
  migration_primary_key: [name: :id, type: :binary_id],
  migration_foreign_key: [type: :binary_id]

config :phoenix, :json_library, Jason

import_config "#{config_env()}.exs"
