defmodule BankCrud.UserManager.RefreshToken do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "refresh_tokens" do
    field(:jti, :string)
    field(:token_hash, :string)
    field(:expires_at, :utc_datetime_usec)
    field(:revoked_at, :utc_datetime_usec)

    belongs_to(:user, BankCrud.UserManager.User)

    timestamps(updated_at: false)
  end

  def changeset(rt, attrs) do
    rt
    |> cast(attrs, [:user_id, :jti, :token_hash, :expires_at, :rekoved_at])
    |> validate_required([:user_id, :jti, :token_hash, :expires_at])
    |> unique_constraint(:jti)
  end
end
