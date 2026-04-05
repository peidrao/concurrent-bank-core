defmodule BankCrudWeb.AccountControllerTest do
  use BankCrudWeb.ConnCase, async: false

  alias BankCrud.Banking

  describe "accounts API" do
    test "creates and fetches an account", %{conn: conn} do
      payload = %{
        number: "0009-01",
        holder_name: "Maria Silva",
        currency: "BRL",
        balance: "150.00",
        status: "active"
      }

      conn = post(conn, "/api/accounts", payload)
      assert %{"data" => created} = json_response(conn, 201)
      assert created["holder_name"] == "Maria Silva"
      assert created["balance"] == "150.00"

      conn = get(recycle(conn), "/api/accounts/#{created["id"]}")
      assert %{"data" => fetched} = json_response(conn, 200)
      assert fetched["id"] == created["id"]
      assert fetched["number"] == "0009-01"
    end

    test "lists accounts in JSON", %{conn: conn} do
      {:ok, _account} =
        Banking.create_account(%{
          number: "0010-01",
          holder_name: "Alice",
          currency: "BRL",
          balance: "20.00",
          status: "active"
        })

      conn = get(conn, "/api/accounts")
      assert %{"data" => data} = json_response(conn, 200)
      assert is_list(data)
      assert Enum.any?(data, fn item -> item["number"] == "0010-01" end)
    end

    test "returns validation errors", %{conn: conn} do
      conn = post(conn, "/api/accounts", %{number: "1"})
      assert %{"errors" => errors} = json_response(conn, 422)
      assert Map.has_key?(errors, "holder_name")
    end
  end
end
