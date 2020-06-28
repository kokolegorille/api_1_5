defmodule Api.Worlds do
  @moduledoc """
  Main module for managing 3D world
  """

  alias Api.Worlds.{
    WorldSup,
    WorldWkr,
    World
  }

  defdelegate start_worker(args), to: WorldSup
  defdelegate list_worlds, to: WorldSup

  defdelegate add_member(worker, user), to: WorldWkr
  defdelegate get_state(worker), to: WorldWkr
  defdelegate join(worker, user), to: WorldWkr
  defdelegate leave(worker, user), to: WorldWkr
  defdelegate remove_member(worker, user), to: WorldWkr
  defdelegate update(worker, id, payload), to: WorldWkr
  defdelegate stop(worker), to: WorldWkr
  defdelegate whereis_name(name), to: WorldWkr

  defdelegate new(attrs), to: World
end
