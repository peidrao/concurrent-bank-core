defmodule BankCrud.Repo do
  use Ecto.Repo,
    otp_app: :bank_crud,
    adapter: Ecto.Adapters.Postgres
end
