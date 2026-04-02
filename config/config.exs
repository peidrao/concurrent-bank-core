import Config

config :bank_crud,
  ecto_repos: [BankCrud.Repo]

config :bank_crud, BankCrud.Repo,
  migration_primary_key: [name: :id, type: :binary_id],
  migration_foreign_key: [type: :binary_id]

import_config "#{config_env()}.exs"
