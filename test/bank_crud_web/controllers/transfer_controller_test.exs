defmodule BankCrudWeb.TransferControllerTest do
  use BankCrudWeb.ConnCase, async: false

  alias BankCrud.Banking

  describe "transfers API" do
    test "creates transfer and updates balances", %{conn: conn} do
      {:ok, from_account} =
        Banking.create_account(%{
          number: "1000-01",
          holder_name: "Sender",
          currency: "BRL",
          balance: "100.00",
          status: "active"
        })

      {:ok, to_account} =
        Banking.create_account(%{
          number: "1000-02",
          holder_name: "Receiver",
          currency: "BRL",
          balance: "0.00",
          status: "active"
        })

      conn =
        post(conn, "/api/transfers", %{
          from_account_id: from_account.id,
          to_account_id: to_account.id,
          amount: "35.50",
          idempotency_key: "transfer-1"
        })

      assert %{"data" => transfer} = json_response(conn, 201)
      assert transfer["amount"] == "35.50"
      assert transfer["status"] == "committed"

      conn = get(recycle(conn), "/api/accounts/#{from_account.id}")
      assert %{"data" => from_after} = json_response(conn, 200)
      assert from_after["balance"] == "64.50"

      conn = get(recycle(conn), "/api/accounts/#{to_account.id}")
      assert %{"data" => to_after} = json_response(conn, 200)
      assert to_after["balance"] == "35.50"
    end

    test "returns insufficient funds error", %{conn: conn} do
      {:ok, from_account} =
        Banking.create_account(%{
          number: "2000-01",
          holder_name: "Low Balance",
          currency: "BRL",
          balance: "10.00",
          status: "active"
        })

      {:ok, to_account} =
        Banking.create_account(%{
          number: "2000-02",
          holder_name: "Receiver",
          currency: "BRL",
          balance: "0.00",
          status: "active"
        })

      conn =
        post(conn, "/api/transfers", %{
          from_account_id: from_account.id,
          to_account_id: to_account.id,
          amount: "99.00"
        })

      assert %{"error" => "insufficient_funds"} = json_response(conn, 422)
    end
  end
end
