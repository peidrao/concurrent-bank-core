defmodule BankCrud.Repo.Migrations.CreateTransfers do
  use Ecto.Migration

  def change do
    create table(:transfers, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :from_account_id, references(:accounts, type: :binary_id, on_delete: :restrict), null: false
      add :to_account_id, references(:accounts, type: :binary_id, on_delete: :restrict), null: false

      add :amount, :decimal, precision: 20, scale: 2, null: false
      add :status, :string, null: false, default: "committed"
      add :idempotency_key, :string

      timestamps(type: :utc_datetime_usec)
    end

    create index(:transfers, [:from_account_id])
    create index(:transfers, [:to_account_id])
    create index(:transfers, [:inserted_at])
    create unique_index(:transfers, [:idempotency_key], where: "idempotency_key IS NOT NULL")

    create constraint(:transfers, :amount_positive, check: "amount > 0")

    create constraint(:transfers, :different_accounts,
             check: "from_account_id <> to_account_id"
           )

    create constraint(:transfers, :valid_status,
             check: "status IN ('committed', 'reversed')"
           )
  end
end
