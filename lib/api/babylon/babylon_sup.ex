defmodule Api.Babylon.BabylonSup do
  @moduledoc """
  The dynamic supervisor
  """

  use DynamicSupervisor
  alias Api.Babylon.BabylonWkr
  @name __MODULE__

  def start_link(_args),
    do: DynamicSupervisor.start_link(__MODULE__, nil, name: @name)

  def start_worker(args \\ %{id: "fake_id"}) do
    case DynamicSupervisor.start_child(__MODULE__, {BabylonWkr, [args]}) do
      {:ok, pid} -> {:ok, pid}
      {:error, {:already_started, pid}} -> {:ok, pid}
    end
  end

  def list_worlds do
    @name
    |> DynamicSupervisor.which_children()
    |> Enum.map(&elem(&1, 1))
    |> Enum.map(&BabylonWkr.get_state(&1))
  end

  def init(_args) do
    opts = [strategy: :one_for_one]
    DynamicSupervisor.init(opts)
  end
end
