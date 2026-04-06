defmodule BankCrudWeb.AuthController do
  use BankCrudWeb, :controller

  alias BankCrud.UserManager

  action_fallback(BankCrudWeb.FallbackController)

  # def login(conn, params) do
  #   with {:ok, user} <- UserManager.authenticate_user(params) do
  #     conn
  #     |> put_status(:ok)
  #   end
  # end

  def create(conn, params) do
    with {:ok, user} <- UserManager.create_user(params) do
      conn
      |> put_status(:created)
      |> json(%{data: user_payload(user)})
    end
  end

  defp user_payload(user) do
    %{
      id: user.id,
      email: user.email,
      name: user.name
    }
  end
end
