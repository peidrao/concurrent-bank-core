defmodule BankCrudWeb.FallbackController do
  use BankCrudWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{errors: errors_on(changeset)})
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> json(%{error: "resource_not_found"})
  end

  def call(conn, {:error, :invalid_amount}) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{error: "invalid_amount"})
  end

  def call(conn, {:error, :invalid_accounts}) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{error: "invalid_accounts"})
  end

  def call(conn, {:error, :same_account}) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{error: "same_account"})
  end

  def call(conn, {:error, :insufficient_funds}) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{error: "insufficient_funds"})
  end

  def call(conn, {:error, :account_not_active}) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{error: "account_not_active"})
  end

  def call(conn, {:error, :account_with_balance}) do
    conn
    |> put_status(:conflict)
    |> json(%{error: "account_with_balance"})
  end

  def call(conn, {:error, _reason}) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "request_failed"})
  end

  defp errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
