defmodule BankCrud do

  alias BankCrud.Banking

  defdelegate list_accounts, to: Banking
  defdelegate get_account(id), to: Banking
  defdelegate create_account(attrs), to: Banking
  defdelegate update_account(account, attrs), to: Banking
  defdelegate delete_account(account), to: Banking

  defdelegate deposit(account_id, amount), to: Banking
  defdelegate withdraw(account_id, amount), to: Banking
  defdelegate transfer(from_account_id, to_account_id, amount, opts \\ []), to: Banking

  defdelegate list_transfers, to: Banking
  defdelegate get_transfer(id), to: Banking
end
