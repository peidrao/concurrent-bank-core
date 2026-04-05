defmodule BankCrud.Banking.Account do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "accounts" do
    field(:number, :string)
    field(:holder_name, :string)
    field(:currency, :string, default: "BRL")
    field(:balance, :decimal, default: Decimal.new("0.00"))
    field(:status, :string, default: "active")
    field(:lock_version, :integer, default: 1)

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(account, attrs) do
    account
    |> cast(attrs, [:number, :holder_name, :currency, :balance, :status])
    |> validate_required([:number, :holder_name, :currency, :status])
    |> validate_length(:number, min: 4, max: 34)
    |> validate_length(:holder_name, min: 3)
    |> validate_inclusion(:status, ["active", "blocked", "closed"])
    |> validate_number(:balance, greater_than_or_equal_to: 0)
    |> unique_constraint(:number)
    |> optimistic_lock(:lock_version)
  end
end
