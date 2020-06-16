defmodule ApiWeb.PageController do
  @moduledoc false
  use ApiWeb, :controller

  def index(conn, _params) do
    conn
    |> put_resp_header("content-type", "text/html; charset=utf-8")
    |> Plug.Conn.send_file(200, "./priv/static/index.html")
  end
end
