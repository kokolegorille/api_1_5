defmodule Api.Rooms.RoomSup do
  @moduledoc """
  The dynamic supervisor
  """

  use DynamicSupervisor
  alias Api.Rooms.RoomWkr
  @name __MODULE__

  def start_link(_args),
    do: DynamicSupervisor.start_link(__MODULE__, nil, name: @name)

  def start_worker(args \\ %{id: "fake_id"}) do
    case DynamicSupervisor.start_child(__MODULE__, {RoomWkr, [args]}) do
      {:ok, pid} -> {:ok, pid}
      {:error, {:already_started, pid}} -> {:ok, pid}
    end
  end

  def list_rooms do
    @name
    |> DynamicSupervisor.which_children()
    |> Enum.map(&elem(&1, 1))
    |> Enum.map(&RoomWkr.get_state(&1))
  end

  def init(_args) do
    opts = [strategy: :one_for_one]
    DynamicSupervisor.init(opts)
  end
end
