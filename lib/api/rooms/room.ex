defmodule Api.Rooms.Room do
  @moduledoc """
  The Room structure
  """

  @fields ~w(
    id name description members presence owner status inserted_at
  )a
  @enforce_keys @fields
  @derive Jason.Encoder
  defstruct id: nil,
            name: nil,
            description: nil,
            members: [],
            presence: [],
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

  def join(%__MODULE__{members: members, presence: presence} = room, user) do
    if Enum.member?(members, user) && not Enum.member?(presence, user) do
      new_presence = [user | presence]
      status = if length(new_presence) >= length(members), do: :running, else: :idle
      {:ok, %{room | presence: new_presence, status: status}}
    else
      {:error, room}
    end
  end

  def leave(%__MODULE__{presence: presence} = room, user) do
    if Enum.member?(presence, user) do
      new_presence = Enum.reject(presence, &(&1 == user))
      status = if Enum.empty?(new_presence), do: :stopped, else: :idle
      {:ok, %{room | presence: new_presence, status: status}}
    else
      {:error, room}
    end
  end
end
