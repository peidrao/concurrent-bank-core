defmodule BankCrud.Banking do
  @moduledoc """
  Contexto de contas e transferências com consistência para alta concorrência.
  """

  import Ecto.Query, warn: false
  alias Ecto.Multi

  alias BankCrud.Banking.{Account, Transfer}
  alias BankCrud.Repo

  @type error_reason ::
          :invalid_amount
          | :invalid_accounts
          | :same_account
          | :insufficient_funds
          | :not_found
          | :account_not_active

  def list_accounts do
    Repo.all(from(a in Account, order_by: [asc: a.inserted_at]))
  end

  def get_account(id), do: Repo.get(Account, id)

  def create_account(attrs) do
    %Account{}
    |> Account.changeset(attrs)
    |> Repo.insert()
  end

  def update_account(%Account{} = account, attrs) do
    account
    |> Account.changeset(attrs)
    |> Repo.update()
  end

  def delete_account(%Account{balance: balance} = account) do
    if Decimal.equal?(balance, Decimal.new("0.00")) do
      Repo.delete(account)
    else
      {:error, :account_with_balance}
    end
  end

  def deposit(account_id, amount) do
    with {:ok, amount} <- cast_positive_amount(amount),
         %Account{} = account <- Repo.get(Account, account_id),
         true <- account.status == "active" do
      {updated_rows, _} =
        from(a in Account, where: a.id == ^account_id)
        |> Repo.update_all(inc: [balance: amount])

      if updated_rows == 1 do
        {:ok, Repo.get(Account, account_id)}
      else
        {:error, :not_found}
      end
    else
      false -> {:error, :account_not_active}
      nil -> {:error, :not_found}
      {:error, _} = error -> error
    end
  end

  def withdraw(account_id, amount) do
    with {:ok, amount} <- cast_positive_amount(amount),
         %Account{} = account <- Repo.get(Account, account_id),
         true <- account.status == "active" do
      {updated_rows, _} =
        from(a in Account,
          where: a.id == ^account_id and a.balance >= ^amount
        )
        |> Repo.update_all(inc: [balance: Decimal.negate(amount)])

      case updated_rows do
        1 -> {:ok, Repo.get(Account, account_id)}
        0 -> {:error, :insufficient_funds}
      end
    else
      false -> {:error, :account_not_active}
      nil -> {:error, :not_found}
      {:error, _} = error -> error
    end
  end

  def transfer(from_account_id, to_account_id, amount, opts \\ []) do
    idempotency_key = Keyword.get(opts, :idempotency_key)

    with {:ok, amount} <- cast_positive_amount(amount),
         :ok <- validate_accounts(from_account_id, to_account_id) do
      Repo.transaction(fn ->
        with {:ok, accounts} <- lock_accounts(from_account_id, to_account_id),
             :ok <- ensure_active_accounts(accounts, from_account_id, to_account_id),
             :ok <- ensure_balance(accounts, from_account_id, amount),
             {:ok, _} <- apply_transfer(from_account_id, to_account_id, amount),
             {:ok, transfer} <-
               create_transfer_record(from_account_id, to_account_id, amount, idempotency_key) do
          transfer
        else
          {:error, reason} -> Repo.rollback(reason)
          {:error, operation, changeset, _changes_so_far} -> Repo.rollback({operation, changeset})
        end
      end)
      |> normalize_tx_result()
    else
      {:error, _} = error -> error
    end
  end

  def list_transfers do
    Repo.all(
      from(t in Transfer,
        preload: [:from_account, :to_account],
        order_by: [desc: t.inserted_at]
      )
    )
  end

  def get_transfer(id) do
    Repo.get(Transfer, id)
    |> Repo.preload([:from_account, :to_account])
  end

  defp cast_positive_amount(amount) do
    case Decimal.cast(amount) do
      {:ok, decimal} ->
        if Decimal.compare(decimal, 0) == :gt do
          {:ok, Decimal.round(decimal, 2)}
        else
          {:error, :invalid_amount}
        end

      :error ->
        {:error, :invalid_amount}
    end
  end

  defp validate_accounts(from_account_id, to_account_id) do
    cond do
      is_nil(from_account_id) or is_nil(to_account_id) -> {:error, :invalid_accounts}
      from_account_id == to_account_id -> {:error, :same_account}
      true -> :ok
    end
  end

  defp lock_accounts(from_account_id, to_account_id) do
    ordered_ids = Enum.sort([from_account_id, to_account_id])

    accounts =
      from(a in Account,
        where: a.id in ^ordered_ids,
        lock: "FOR UPDATE"
      )
      |> Repo.all()

    if length(accounts) == 2 do
      {:ok, accounts}
    else
      {:error, :not_found}
    end
  end

  defp ensure_active_accounts(accounts, from_account_id, to_account_id) do
    from_account = Enum.find(accounts, &(&1.id == from_account_id))
    to_account = Enum.find(accounts, &(&1.id == to_account_id))

    cond do
      from_account.status != "active" -> {:error, :account_not_active}
      to_account.status != "active" -> {:error, :account_not_active}
      true -> :ok
    end
  end

  defp ensure_balance(accounts, from_account_id, amount) do
    from_account = Enum.find(accounts, &(&1.id == from_account_id))

    if Decimal.compare(from_account.balance, amount) in [:gt, :eq] do
      :ok
    else
      {:error, :insufficient_funds}
    end
  end

  defp apply_transfer(from_account_id, to_account_id, amount) do
    Multi.new()
    |> Multi.update_all(
      :debit,
      from(a in Account, where: a.id == ^from_account_id),
      inc: [balance: Decimal.negate(amount)]
    )
    |> Multi.update_all(
      :credit,
      from(a in Account, where: a.id == ^to_account_id),
      inc: [balance: amount]
    )
    |> Repo.transaction()
    |> case do
      {:ok, _} -> {:ok, :applied}
      {:error, _operation, _failed_value, _changes} -> {:error, :transfer_failed}
    end
  end

  defp create_transfer_record(from_account_id, to_account_id, amount, idempotency_key) do
    %Transfer{}
    |> Transfer.changeset(%{
      from_account_id: from_account_id,
      to_account_id: to_account_id,
      amount: amount,
      status: "committed",
      idempotency_key: idempotency_key
    })
    |> Repo.insert()
  end

  defp normalize_tx_result({:ok, transfer}), do: {:ok, transfer}

  defp normalize_tx_result({:error, {_operation, changeset}}), do: {:error, changeset}

  defp normalize_tx_result({:error, reason}) when is_atom(reason), do: {:error, reason}

  defp normalize_tx_result(other), do: other
end
