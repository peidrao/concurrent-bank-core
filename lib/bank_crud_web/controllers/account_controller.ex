defmodule BankCrudWeb.AccountController do
  use BankCrudWeb, :controller

  alias BankCrud.Banking
  alias BankCrud.Banking.Account

  action_fallback(BankCrudWeb.FallbackController)

  def index(conn, _params) do
    accounts = Banking.list_accounts()
    json(conn, %{data: Enum.map(accounts, &account_payload/1)})
  end

  def create(conn, params) do
    with {:ok, account} <- Banking.create_account(params) do
      conn
      |> put_status(:created)
      |> json(%{data: account_payload(account)})
    end
  end

  def show(conn, %{"id" => id}) do
    case Banking.get_account(id) do
      nil ->
        {:error, :not_found}

      account ->
        json(conn, %{data: account_payload(account)})
    end
  end

  def update(conn, %{"id" => id} = params) do
    with %Account{} = account <- Banking.get_account(id),
         attrs = Map.drop(params, ["id"]),
         {:ok, updated_account} <- Banking.update_account(account, attrs) do
      json(conn, %{data: account_payload(updated_account)})
    else
      nil -> {:error, :not_found}
      error -> error
    end
  end

  def delete(conn, %{"id" => id}) do
    with %Account{} = account <- Banking.get_account(id),
         {:ok, _deleted_account} <- Banking.delete_account(account) do
      send_resp(conn, :no_content, "")
    else
      nil -> {:error, :not_found}
      error -> error
    end
  end

  def deposit(conn, %{"id" => id, "amount" => amount}) do
    with {:ok, account} <- Banking.deposit(id, amount) do
      json(conn, %{data: account_payload(account)})
    end
  end

  def deposit(_conn, _params), do: {:error, :invalid_amount}

  def withdraw(conn, %{"id" => id, "amount" => amount}) do
    with {:ok, account} <- Banking.withdraw(id, amount) do
      json(conn, %{data: account_payload(account)})
    end
  end

  def withdraw(_conn, _params), do: {:error, :invalid_amount}

  defp account_payload(account) do
    %{
      id: account.id,
      number: account.number,
      holder_name: account.holder_name,
      currency: account.currency,
      balance: Decimal.to_string(account.balance, :normal),
      status: account.status,
      inserted_at: account.inserted_at,
      updated_at: account.updated_at
    }
  end
end
