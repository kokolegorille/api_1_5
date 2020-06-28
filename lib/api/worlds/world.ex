defmodule Api.Worlds.World do
  @moduledoc """
  The World structure for 3D world
  """

  alias Api.Worlds.{Player, Helpers}

  @max_size 500
  @max_presences 10

  @derive Jason.Encoder

  defstruct id: nil,
            owner: nil,
            members: [],
            presences: [],
            #
            name: nil,
            description: nil,
            players: %{},
            #
            access: :public,
            status: :started,
            inserted_at: nil

  def new(attrs), do: struct(__MODULE__, attrs)

  def join(
        %__MODULE__{access: :public, presences: presences, players: players} = world,
        player
      ) do
    with {:ok, presences} <- maybe_add_player(presences, player),
         true <- length(presences) <= @max_presences do
      new_world_player = create_player(player.id, Helpers.random_player(@max_size))
      players = Map.put(players, player.id, new_world_player)

      {:ok, %{world | presences: presences, status: :running, players: players}}
    else
      false -> {:error, "World is full"}
      {:error, reason} -> {:error, reason}
    end
  end

  def join(
        %__MODULE__{members: members, presences: presences, players: players} = world,
        player
      ) do
    with {:one, true} <- {:one, Enum.member?(members, player)},
         {:ok, presences} <- maybe_add_player(presences, player),
         true <- length(presences) <= @max_presences do
      new_world_player = create_player(player.id, Helpers.random_player(@max_size))
      players = Map.put(players, player.id, new_world_player)

      {:ok, %{world | presences: presences, status: :running, players: players}}
    else
      {:one, false} -> {:error, "Player is not a member"}
      false -> {:error, "World is full"}
      {:error, reason} -> {:error, reason}
    end
  end

  defp maybe_add_player(presences, player) do
    if Enum.member?(presences, player),
      do: {:error, "Player is already in the world"},
      else: {:ok, [player | presences]}
  end

  defp create_player(player_id, attrs) do
    Player.new(Map.merge(attrs, %{id: player_id, inserted_at: DateTime.utc_now()}))
  end

  def leave(
        %__MODULE__{presences: presences, players: players} = world,
        player
      ) do
    if Enum.member?(presences, player) do
      presences = Enum.reject(presences, &(&1 == player))
      status = if Enum.empty?(presences), do: :stopped, else: :running
      players = Map.delete(players, player.id)

      {:ok, %{world | presences: presences, status: status, players: players}}
    else
      {:error, "error leaving the world"}
    end
  end

  def add_member(%__MODULE__{members: members} = world, player) do
    members =
      if Enum.member?(members, player),
        do: members,
        else: [player | members]

    {:ok, %{world | members: members}}
  end

  def remove_member(%__MODULE__{members: members} = world, player) do
    {:ok, %{world | members: Enum.reject(members, &(&1 == player))}}
  end

  def update(%__MODULE__{} = world, id, payload) do
    Map.update!(world, id, &struct(&1, payload))
  end
end
