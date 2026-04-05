defmodule BankCrud.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      BankCrud.Repo,
      BankCrudWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: BankCrud.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    BankCrudWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
