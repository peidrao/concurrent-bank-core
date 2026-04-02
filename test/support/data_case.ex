defmodule BankCrud.DataCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias BankCrud.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import BankCrud.DataCase
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(BankCrud.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(BankCrud.Repo, {:shared, self()})
    end

    :ok
  end
end
