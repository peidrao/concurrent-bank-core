ExUnit.start()

Code.require_file("support/data_case.ex", __DIR__)
Code.require_file("support/conn_case.ex", __DIR__)
Code.require_file("support/fixtures/user_manager_fixtures.ex", __DIR__)

Ecto.Adapters.SQL.Sandbox.mode(BankCrud.Repo, :manual)
