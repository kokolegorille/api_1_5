defmodule ApiWeb.Api.RegistrationControllerTest do
  use ApiWeb.ConnCase

  alias Api.Accounts

  @valid_attrs %{
    name: "koko",
    email: "koko@example.com",
    password: "password"
  }

  describe "POST /api/registration" do
    setup do
      user =
        case Accounts.get_user_by_name(@valid_attrs.name) do
          nil ->
            user_fixture(@valid_attrs)

          user ->
            user
        end

      {:ok, user: user}
    end

    # Happy path
    test "can create user", %{conn: conn} do
      user = %{
        "name" => "kiki",
        "email" => "kiki@example.com",
        "password" => "password"
      }

      conn = post(conn, "/api/registration", %{"user" => user})
      json = json_response(conn, 201)

      assert is_map(json) && Map.get(json, "user")
    end

    # Error path
    test "cannot duplicate user name", %{conn: conn} do
      user = @valid_attrs
      conn = post(conn, "/api/registration", %{"user" => user})

      json = json_response(conn, 422)
      assert is_map(json) && Enum.count(Map.get(json, "errors")) > 0
    end

    test "cannot create user with invalid params", %{conn: conn} do
      user = %{"password" => "password"}
      conn = post(conn, "/api/registration", %{"user" => user})

      json = json_response(conn, 422)
      assert is_map(json) && Enum.count(Map.get(json, "errors")) > 0
    end
  end

  defp user_fixture(attrs) do
    {:ok, user} = Accounts.create_user(attrs)
    user
  end
end
