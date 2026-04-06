defmodule BankCrudWeb.Router do
  use BankCrudWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/api", BankCrudWeb do
    pipe_through(:api)

    resources("/accounts", AccountController, except: [:new, :edit])
    post("/accounts/:id/deposit", AccountController, :deposit)
    post("/accounts/:id/withdraw", AccountController, :withdraw)

    resources("/transfers", TransferController, only: [:index, :show, :create])

    post("/users/create", AuthController, :create)
  end
end
