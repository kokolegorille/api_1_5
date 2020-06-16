defmodule Api.Rooms.RoomWkr do
  @moduledoc """
  The worker module
  """

  use GenServer
  require Logger

  alias Registry.Rooms, as: RegRooms

  def child_spec(args) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, args},
      restart: :transient,
      shutdown: 5000,
      type: :worker
    }
  end

  def start_link(args) do
    name = args.id
    GenServer.start_link(__MODULE__, args, name: via(name))
  end

  def get_state(worker), do: GenServer.call(worker, :get_state)

  def stop(worker), do: GenServer.cast(worker, :stop)

  def whereis_name(name) do
    case Registry.lookup(RegRooms, name) do
      [{pid, _ref}] -> pid
      [] -> nil
    end
  end

  @impl GenServer
  def init(record) do
    Logger.info "#{__MODULE__} is starting with args #{inspect record}"
    {:ok, record}
  end

  @impl GenServer
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  @impl GenServer
  def handle_cast(:stop, state), do: {:stop, :normal, state}

  @impl GenServer
  def terminate(reason, _state) do
    Logger.info "#{__MODULE__} stopped : #{inspect(reason)}"
    :ok
  end

  # Private

  defp via(name), do: {:via, Registry, {RegRooms, name}}
end
