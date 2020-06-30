defmodule ApiWeb.AuthSessionControllerTest do
  use ApiWeb.ConnCase

  alias Api.Accounts
  alias ApiWeb.TokenHelpers

  @valid_attrs %{
    name: "koko",
    email: "koko@example.com",
    password: "password"
  }

  setup do
    user =
      case Accounts.get_user_by_name(@valid_attrs.name) do
        nil ->
          user_fixture(@valid_attrs)

        user ->
          user
      end

    token = sign_user_token(user)

    # Create an authentified connection with valid token
    # http://blog.overstuffedgorilla.com/simple-guardian-api-authentication/
    auth_conn =
      build_conn()
      |> put_req_header("authorization", "Bearer #{token}")

    {:ok, %{token: token, conn: auth_conn}}
  end

  describe "DELETE /api/authentication" do
    # Happy path
    test "can delete session", %{conn: conn} do
      conn =
        conn
        |> delete("/api/authentication")

      json = json_response(conn, 200)
      assert is_map(json) && Map.get(json, "ok")
    end

    # There is no reason to have an error path unless if you use guardian_db
    # Because as long as you have a valid token, there will be no invalidation!
  end

  describe "PATCH /api/authentication/refresh" do
    # Happy path
    test "can refresh tokens session", %{token: token, conn: conn} do
      session = %{"token" => token}

      conn =
        conn
        |> patch("/api/authentication/refresh", %{"session" => session})

      # 201 status = created
      json = json_response(conn, 201)
      assert is_map(json) && Map.get(json, "user") && Map.get(json, "token")
    end

    # This test is obsolete, because refresh is a secure path...
    # There is no need to pass a token, as this one is passed in headers
    # and checked via plugs!

    # Error path
    # test "cannot refresh with bad parameters", %{token: _token, conn: conn} do
    #   session = %{"token" => "fake_token"}
    #
    #   conn = conn
    #   |> patch("/api/v1/authentication/refresh", %{"session" => session})
    #
    #   json = json_response(conn, 422)
    #   assert is_map(json) && Map.get(json, "error")
    # end
  end

  defp user_fixture(attrs) do
    {:ok, user} = attrs |> Accounts.create_user()
    user
  end

  defp sign_user_token(user), do: TokenHelpers.sign(user)
end
