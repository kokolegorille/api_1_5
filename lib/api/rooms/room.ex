defmodule Api.Rooms.Room do
  @moduledoc """
  The Room structure
  """

  @fields ~w(
    id name description members presences owner status inserted_at
  )a
  @enforce_keys @fields
  @derive Jason.Encoder
  defstruct id: nil,
            name: nil,
            description: nil,
            members: [],
            presences: [],
            owner: nil,
            status: :started,
            inserted_at: nil

  def new(attrs) do
    attrs =
      Map.merge(
        %{id: UUID.uuid4(), inserted_at: DateTime.utc_now()},
        attrs
      )

    struct(__MODULE__, attrs)
  end

  def join(%__MODULE__{members: members, presences: presences} = room, user) do
    if Enum.member?(members, user) && not Enum.member?(presences, user) do
      new_presences = [user | presences]
      status = if length(new_presences) >= length(members),
        do: :running, else: :idle
      {:ok, %{room | presences: new_presences, status: status}}
    else
      {:error, room}
    end
  end

  def leave(%__MODULE__{presences: presences} = room, user) do
    if Enum.member?(presences, user) do
      new_presences = Enum.reject(presences, &(&1 == user))
      status = if Enum.empty?(new_presences), do: :stopped, else: :idle
      {:ok, %{room | presences: new_presences, status: status}}
    else
      {:error, room}
    end
  end
end
