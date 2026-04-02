defmodule BankCrud.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :number, :string, null: false
      add :holder_name, :string, null: false
      add :currency, :string, null: false, default: "BRL"
      add :balance, :decimal, precision: 20, scale: 2, null: false, default: 0
      add :status, :string, null: false, default: "active"
      add :lock_version, :integer, null: false, default: 1

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:accounts, [:number])
    create index(:accounts, [:status])

    create constraint(:accounts, :balance_non_negative, check: "balance >= 0")

    create constraint(:accounts, :valid_status,
             check: "status IN ('active', 'blocked', 'closed')"
           )
  end
end
