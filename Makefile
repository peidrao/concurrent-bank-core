.PHONY: help test-setup test test-reset

help:
	@echo "Available targets:"
	@echo "  make test-setup  - Create and migrate test database"
	@echo "  make test        - Setup test database and run tests"
	@echo "  make test-reset  - Drop, recreate, migrate test database, then run tests"

test-setup:
	MIX_ENV=test mix ecto.create
	MIX_ENV=test mix ecto.migrate

test: test-setup
	mix test

test-reset:
	MIX_ENV=test mix ecto.drop
	MIX_ENV=test mix ecto.create
	MIX_ENV=test mix ecto.migrate
	mix test
