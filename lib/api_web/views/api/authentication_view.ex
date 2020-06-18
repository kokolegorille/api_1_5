defmodule ApiWeb.Api.AuthenticationView do
  @moduledoc false
  use ApiWeb, :view

  def render("show.json", %{token: token, user: user}), do: %{token: token, user: user_json(user)}

  def render("refresh_error.json", _), do: %{error: "Invalid token"}

  def render("delete.json", _), do: %{ok: true}

  def render("error.json", %{changeset: changeset}) do
    %{
      status: "failure",
      errors: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
    }
  end

  def render("error.json", _), do: %{error: "Invalid username or password"}

  def render("forbidden.json", %{error: error}), do: %{error: error}

  # PRIVATE

  defp user_json(user), do: %{id: user.id, name: user.name}
end
