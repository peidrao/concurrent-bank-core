defmodule BankCrud.UserManager.Guardian do
  use Guardian, otp_app: :bank_crud

  alias BankCrud.UserManager

  @impl true
  @spec subject_for_token(any(), any()) :: {:ok, binary()}
  def subject_for_token(user, _claims) do
    {:ok, to_string(user.id)}
  end

  @impl true
  def resource_from_claims(%{"sub" => id}) do
    user = UserManager.get_user!(id)
    {:ok, user}
  rescue
    Ecto.NoResultsError -> {:error, :resource_not_found}
  end
end
