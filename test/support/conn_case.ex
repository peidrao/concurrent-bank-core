defmodule BankCrudWeb.ConnCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      @endpoint BankCrudWeb.Endpoint

      use BankCrudWeb, :controller
      import Plug.Conn
      import Phoenix.ConnTest
      import BankCrudWeb.ConnCase
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(BankCrud.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(BankCrud.Repo, {:shared, self()})
    end

    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
