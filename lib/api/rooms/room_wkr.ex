defmodule Api.Rooms.RoomWkr do
  @moduledoc """
  The worker module
  """

  use GenServer
  require Logger

  alias Registry.Rooms, as: RegRooms
  alias Api.Rooms.Room
  alias Api.Rooms.RoomMonitor

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

  def join(nil, _user), do: Logger.info("No worker available")

  def join(worker, user)
      when is_pid(worker),
      do: GenServer.call(worker, {:join, user})

  def leave(nil, _user), do: Logger.info("No worker available")

  def leave(worker, user)
      when is_pid(worker),
      do: GenServer.call(worker, {:leave, user})

  @impl GenServer
  def init(record) do
    Logger.info("#{__MODULE__} is starting with args #{inspect(record)}")

    RoomMonitor.monitor_room(
      self(),
      %{topic: "room", room_state: record}
    )

    {:ok, record}
  end

  @impl GenServer
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  @impl GenServer
  def handle_call({:join, user}, _from, state) do
    case Room.join(state, user) do
      {:ok, new_state} ->
        {:reply, {:ok, new_state}, new_state}

      {:error, _state} ->
        {:reply, {:error, "Join room failure #{inspect(state)}"}, state}
    end
  end

  @impl GenServer
  def handle_call({:leave, user}, _from, state) do
    case Room.leave(state, user) do
      {:ok, %{presences: presences} = new_state} when presences == [] ->
        {:stop, :normal, new_state, new_state}

      {:ok, new_state} ->
        {:reply, {:ok, new_state}, new_state}

      {:error, _state} ->
        {:reply, {:error, "Leave room failure #{inspect(state)}"}, state}
    end
  end

  @impl GenServer
  def handle_cast(:stop, state), do: {:stop, :normal, state}

  @impl GenServer
  def terminate(reason, _state) do
    Logger.info("#{__MODULE__} stopped : #{inspect(reason)}")
    :ok
  end

  # Private

  defp via(name), do: {:via, Registry, {RegRooms, name}}
end
