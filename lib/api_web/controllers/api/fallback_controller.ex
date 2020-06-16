defmodule ApiWeb.Api.FallbackController do
  use ApiWeb, :controller
  alias ApiWeb.Api.AuthenticationView

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(AuthenticationView)
    |> render("error.json")
  end

  def call(conn, {:error, reason}) do
    conn
    |> put_status(:unauthorized)
    |> put_view(AuthenticationView)
    |> render("forbidden.json", error: reason)
  end
end
