defmodule BankCrud.UserManagerTest do
  use BankCrud.DataCase

  alias BankCrud.UserManager

  describe "users" do
    alias BankCrud.UserManager.User

    import BankCrud.UserManagerFixtures

    @invalid_attrs %{username: nil, password: nil}

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert UserManager.list_users() == [%{user | password: nil}]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert UserManager.get_user!(user.id) == %{user | password: nil}
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{email: "some@email.com", password: "some password", name: "some name"}

      assert {:ok, %User{} = user} = UserManager.create_user(valid_attrs)
      assert user.email == "some@email.com"
      assert user.name == "some name"
      assert Argon2.verify_pass("some password", user.password_hash)
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = UserManager.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      update_attrs = %{email: "some@updated.email", password: "some updated password", name: "some updated name"}

      assert {:ok, %User{} = user} = UserManager.update_user(user, update_attrs)
      assert user.email == "some@updated.email"
      assert user.name == "some updated name"
      assert Argon2.verify_pass("some updated password", user.password_hash)
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = UserManager.update_user(user, @invalid_attrs)
      assert %{user | password: nil} == UserManager.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = UserManager.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> UserManager.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = UserManager.change_user(user)
    end
  end
end
