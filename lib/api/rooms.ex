defmodule Api.Rooms do
  @moduledoc """
  The scheduler module
  """

  alias Api.Rooms.{
    RoomSup,
    RoomWkr,
    Room
  }

  defdelegate start_worker(args), to: RoomSup
  defdelegate list_rooms, to: RoomSup

  defdelegate whereis_name(name), to: RoomWkr
  defdelegate join(worker, user), to: RoomWkr
  defdelegate leave(worker, user), to: RoomWkr

  defdelegate new(attrs), to: Room
end
