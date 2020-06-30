defmodule Api.Accounts.UserTest do
  use Api.DataCase

  alias Api.Accounts
  alias Accounts.User

  @valid_attrs %{name: "koko", email: "koko@example.com", password: "password"}
  @invalid_attrs %{}

  describe "happy path" do
    test "changeset with valid attributes" do
      changeset = User.registration_changeset(%User{}, @valid_attrs)
      assert changeset.valid?
    end
  end

  describe "error path" do
    test "changeset with invalid attributes" do
      changeset = User.registration_changeset(%User{}, @invalid_attrs)
      refute changeset.valid?
    end

    # Multiple attributes testing
    test "changeset with missing attributes" do
      [:name, :email, :password]
      |> Enum.each(fn attr ->
        missing_params = Map.update(@valid_attrs, attr, nil, &(&1 = nil))
        changeset = User.registration_changeset(%User{}, missing_params)
        assert "can't be blank" in errors_on(changeset)[attr]
        refute changeset.valid?
      end)
    end

    test "changeset with too long name attribute" do
      too_long_name_params = %{@valid_attrs | name: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"}
      changeset = User.registration_changeset(%User{}, too_long_name_params)
      assert %{name: ["should be at most 32 character(s)"]} = errors_on(changeset)
      refute changeset.valid?
    end

    test "changeset with too long password attribute" do
      too_long_password_params = %{@valid_attrs | password: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"}
      changeset = User.registration_changeset(%User{}, too_long_password_params)
      assert %{password: ["should be at most 32 character(s)"]} = errors_on(changeset)
      refute changeset.valid?
    end

    test "changeset with too short password attribute" do
      too_short_password_params = %{@valid_attrs | password: "aaaaa"}
      changeset = User.registration_changeset(%User{}, too_short_password_params)
      assert %{password: ["should be at least 6 character(s)"]} = errors_on(changeset)
      refute changeset.valid?
    end

    test "changeset with invalid email attribute" do
      invalid_email_params = %{@valid_attrs | email: "not_an_email"}
      changeset = User.registration_changeset(%User{}, invalid_email_params)
      assert %{email: ["has invalid format"]} = errors_on(changeset)
      refute changeset.valid?
    end
  end

  describe "duplicate path" do
    setup do
      user =
        case Accounts.get_user_by_name(@valid_attrs.name) do
          nil ->
            {:ok, user} = Accounts.create_user(@valid_attrs)
            user
          user -> user
        end
      {:ok, user: user}
    end

    test "changeset with duplicate name attribute" do
      duplicate_name_params = %{@valid_attrs | email: "different@example.com"}
      assert {:error, changeset} = Accounts.create_user(duplicate_name_params)
      assert %{name: ["Name already taken"]} = errors_on(changeset)
      refute changeset.valid?
    end

    test "changeset with duplicate email attribute" do
      duplicate_email_params = %{@valid_attrs | name: "different_name"}
      assert {:error, changeset} = Accounts.create_user(duplicate_email_params)
      assert %{email: ["Email already taken"]} = errors_on(changeset)
      refute changeset.valid?
    end
  end

  describe "update user path" do
    test "update user" do
      user_params = %{name: "kiki", email: "kiki@example.com", password: "password"}
      update_attrs = %{name: "updated", email: "updated@example.com", password: "password"}

      {:ok, user} = Accounts.create_user(user_params)
      {:ok, user} = Accounts.update_user(user, update_attrs)
      assert user.name == update_attrs.name
      assert user.email == update_attrs.email
    end
  end

  describe "delete user path" do
    test "delete user" do
      user_params = %{name: "kuku", email: "kuku@example.com", password: "password"}
      {:ok, user} = Accounts.create_user(user_params)
      Accounts.delete_user(user)

      assert Accounts.get_user_by_name(user_params.name) == nil
    end
  end
end
