# Bank CRUD (Elixir + PostgreSQL)

CRUD simples de contas bancárias com operações seguras para alta concorrência.

## Stack

- Elixir + Ecto SQL
- PostgreSQL
- Estratégia de concorrência:
  - `UPDATE ... inc` atômico para depósito/saque
  - `FOR UPDATE` + transação para transferência
  - constraints no banco para integridade

## Subir banco

```bash
docker compose up -d
```

## Rodar projeto

```bash
cd bank_crud
mix deps.get
mix ecto.create
mix ecto.migrate
mix test
```

## Exemplo no IEx

```bash
iex -S mix
```

```elixir
alias BankCrud.Banking

{:ok, a1} = Banking.create_account(%{
  number: "ACC-1001",
  holder_name: "João",
  currency: "BRL",
  balance: "1000.00",
  status: "active"
})

{:ok, a2} = Banking.create_account(%{
  number: "ACC-1002",
  holder_name: "Ana",
  currency: "BRL",
  balance: "100.00",
  status: "active"
})

{:ok, _} = Banking.deposit(a1.id, "50.00")
{:ok, _} = Banking.withdraw(a2.id, "20.00")
{:ok, transfer} = Banking.transfer(a1.id, a2.id, "150.00", idempotency_key: "tx-001")

Banking.list_accounts()
Banking.get_transfer(transfer.id)
```

## CRUD disponível

- Contas:
  - `create_account/1`
  - `list_accounts/0`
  - `get_account/1`
  - `update_account/2`
  - `delete_account/1` (somente saldo 0)
- Transferências:
  - `list_transfers/0`
  - `get_transfer/1`

## Observações

- Este projeto foi escrito para ser simples e direto, mantendo consistência sob concorrência.
