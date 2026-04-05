defmodule BankCrudWeb.TransferController do
  use BankCrudWeb, :controller

  alias BankCrud.Banking

  action_fallback(BankCrudWeb.FallbackController)

  def index(conn, _params) do
    transfers = Banking.list_transfers()
    json(conn, %{data: Enum.map(transfers, &transfer_payload/1)})
  end

  def show(conn, %{"id" => id}) do
    case Banking.get_transfer(id) do
      nil ->
        {:error, :not_found}

      transfer ->
        json(conn, %{data: transfer_payload(transfer)})
    end
  end

  def create(
        conn,
        %{"from_account_id" => from_id, "to_account_id" => to_id, "amount" => amount} = params
      ) do
    opts =
      case Map.get(params, "idempotency_key") do
        nil -> []
        key -> [idempotency_key: key]
      end

    with {:ok, transfer} <- Banking.transfer(from_id, to_id, amount, opts) do
      conn
      |> put_status(:created)
      |> json(%{data: transfer_payload(transfer)})
    end
  end

  def create(_conn, _params), do: {:error, :invalid_accounts}

  defp transfer_payload(transfer) do
    %{
      id: transfer.id,
      from_account_id: transfer.from_account_id,
      to_account_id: transfer.to_account_id,
      amount: Decimal.to_string(transfer.amount, :normal),
      status: transfer.status,
      idempotency_key: transfer.idempotency_key,
      inserted_at: transfer.inserted_at,
      updated_at: transfer.updated_at
    }
  end
end
