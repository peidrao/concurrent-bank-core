defmodule BankCrud.MixProject do
  use Mix.Project

  def project do
    [
      app: :bank_crud,
      version: "0.1.1",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :runtime_tools],
      mod: {BankCrud.Application, []}
    ]
  end

  defp deps do
    [
      {:phoenix, "~> 1.7.14"},
      {:ecto_sql, "~> 3.12"},
      {:postgrex, ">= 0.0.0"},
      {:jason, "~> 1.4"},
      {:plug_cowboy, "~> 2.7"}
    ]
  end
end
