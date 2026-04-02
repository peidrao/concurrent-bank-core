defmodule BankCrud.BankingTest do
  use BankCrud.DataCase, async: false

  alias BankCrud.Banking

  test "crud de conta" do
    {:ok, account} =
      Banking.create_account(%{
        number: "0001-01",
        holder_name: "Maria Silva",
        currency: "BRL",
        balance: "100.00",
        status: "active"
      })

    assert account.holder_name == "Maria Silva"

    {:ok, account} = Banking.update_account(account, %{holder_name: "Maria S."})
    assert account.holder_name == "Maria S."

    fetched = Banking.get_account(account.id)
    assert fetched.id == account.id

    {:ok, _} = Banking.withdraw(account.id, "100.00")
    {:ok, _} = Banking.delete_account(Banking.get_account(account.id))
  end

  test "transferencia com lock transacional" do
    {:ok, from} =
      Banking.create_account(%{
        number: "0001-10",
        holder_name: "Alice",
        currency: "BRL",
        balance: "1000.00",
        status: "active"
      })

    {:ok, to} =
      Banking.create_account(%{
        number: "0001-11",
        holder_name: "Bob",
        currency: "BRL",
        balance: "0.00",
        status: "active"
      })

    stream =
      1..50
      |> Task.async_stream(
        fn _ -> Banking.transfer(from.id, to.id, "10.00") end,
        max_concurrency: 50,
        timeout: 15_000
      )
      |> Enum.to_list()

    assert Enum.all?(stream, fn {:ok, {:ok, _transfer}} -> true; _ -> false end)

    from_after = Banking.get_account(from.id)
    to_after = Banking.get_account(to.id)

    assert Decimal.equal?(from_after.balance, Decimal.new("500.00"))
    assert Decimal.equal?(to_after.balance, Decimal.new("500.00"))
  end
end
