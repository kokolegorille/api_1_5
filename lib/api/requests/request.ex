defmodule Api.Requests.Request do
  @moduledoc """
  The request structure
  """

  @fields ~w(uuid name description owner inserted_at)a
  @enforce_keys @fields
  defstruct @fields

  def new(name, description, owner) do
    attrs = %{
      uuid: UUID.uuid4(),
      name: name,
      description: description,
      owner: owner,
      inserted_at: DateTime.utc_now()
    }
    struct(__MODULE__, attrs)
  end
end
