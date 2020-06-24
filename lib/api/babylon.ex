defmodule Api.Babylon do
  @moduledoc """
  Main module for managing Babylonjs world
  """

  alias Api.Babylon.{
    BabylonSup,
    BabylonWkr,
    World
  }

  defdelegate start_worker(args), to: BabylonSup
  defdelegate list_worlds, to: BabylonSup

  defdelegate add_member(worker, user), to: BabylonWkr
  defdelegate get_state(worker), to: BabylonWkr
  defdelegate join(worker, user), to: BabylonWkr
  defdelegate leave(worker, user), to: BabylonWkr
  defdelegate remove_member(worker, user), to: BabylonWkr
  defdelegate update(worker, id, payload), to: BabylonWkr
  defdelegate stop(worker), to: BabylonWkr
  defdelegate whereis_name(name), to: BabylonWkr

  defdelegate new(attrs), to: World
end
