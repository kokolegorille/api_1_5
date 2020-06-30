defmodule ApiWeb.Api.AuthenticationControllerTest do
  use ApiWeb.ConnCase

  alias Api.Accounts

  @valid_attrs %{
    name: "koko",
    email: "koko@example.com",
    password: "password"
  }

  describe "POST /api/authentication" do
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
    test "can create session", %{conn: conn} do
      session = %{"name" => "koko", "password" => "password"}
      conn = post(conn, "/api/authentication", %{"session" => session})

      # 201 status = created
      json = json_response(conn, 201)

      assert is_map(json) && Map.get(json, "user") && Map.get(json, "token")
    end

    # Error path
    test "cannot sign in with bad parameters", %{conn: conn} do
      session = %{"name" => "koko", "password" => "BADpassword"}

      conn = post(conn, "/api/authentication", %{"session" => session})
      json = json_response(conn, 404)

      assert json == %{"error" => "Invalid username or password"}
    end
  end

  ## RESTRICTED AREA WITH TOKEN REQUESTED!

  describe "DELETE /api/authentication" do
    # Error path
    test "cannot access delete session", %{conn: conn} do
      conn =
        conn
        |> delete("/api/authentication")

      json = json_response(conn, 401)
      assert is_map(json) && Map.get(json, "error")
    end
  end

  describe "PATCH /api/authentication/refresh" do
    # Error path
    test "cannot access refresh", %{conn: conn} do
      # You don't need to pass a token, as one is passed via headers!

      # session = %{"token" => "fake_token"}
      session = %{}

      conn =
        conn
        |> patch("/api/authentication/refresh", %{"session" => session})

      json = json_response(conn, 401)
      assert is_map(json) && Map.get(json, "error")
    end
  end

  ## END RESTRICTED AREA

  defp user_fixture(attrs) do
    {:ok, user} = attrs |> Accounts.create_user()
    user
  end
end
