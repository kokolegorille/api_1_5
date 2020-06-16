defmodule Api.Rooms do
  @moduledoc """
  The scheduler module
  """

  alias Api.Rooms.{
    RoomSup,
    RoomWkr
  }

  defdelegate whereis_name(name), to: RoomWkr
  defdelegate start_worker(args), to: RoomSup

  def list_rooms do
    list_workers()
    |> Enum.map(& RoomWkr.get_state(&1))
  end

  # Returns the list of worker pids
  def list_workers do
    RoomSup
    |> DynamicSupervisor.which_children()
    |> Enum.map(& elem(&1, 1))
  end
end
