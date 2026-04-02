defmodule BankCrud.Banking.Transfer do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "transfers" do
    field :amount, :decimal
    field :status, :string, default: "committed"
    field :idempotency_key, :string

    belongs_to :from_account, BankCrud.Banking.Account
    belongs_to :to_account, BankCrud.Banking.Account

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(transfer, attrs) do
    transfer
    |> cast(attrs, [:from_account_id, :to_account_id, :amount, :status, :idempotency_key])
    |> validate_required([:from_account_id, :to_account_id, :amount, :status])
    |> validate_number(:amount, greater_than: 0)
    |> validate_inclusion(:status, ["committed", "reversed"])
    |> foreign_key_constraint(:from_account_id)
    |> foreign_key_constraint(:to_account_id)
    |> unique_constraint(:idempotency_key)
    |> validate_different_accounts()
  end

  defp validate_different_accounts(changeset) do
    from_account_id = get_field(changeset, :from_account_id)
    to_account_id = get_field(changeset, :to_account_id)

    if from_account_id && to_account_id && from_account_id == to_account_id do
      add_error(changeset, :to_account_id, "must be different from from_account_id")
    else
      changeset
    end
  end
end
