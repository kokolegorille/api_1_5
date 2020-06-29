defmodule Api.Worlds.WorldWkr do
  @moduledoc """
  The worker module
  """

  use GenServer
  require Logger

  # time of inactivity before the worker stop
  @timeout 5 * 60 * 60 * 1_000

  # grace period time before the worker shutdown by timeout...
  # This will keep the process alive for a short period
  # after worker presences drop to 0
  @grace_period 5_000

  alias Registry.Worlds, as: RegWorlds
  alias Api.Worlds.World
  alias Api.WorkerMonitor

  def child_spec(args) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, args},
      restart: :transient,
      shutdown: 5000,
      type: :worker
    }
  end

  # Separate the worker inner state from the world state
  defstruct [
    world_state: nil,
    grace_timer: nil
  ]

  def start_link(args) do
    name = args.id
    GenServer.start_link(__MODULE__, args, name: via(name))
  end

  def add_member(worker, user)
      when is_pid(worker),
      do: GenServer.call(worker, {:add_member, user})

  def get_state(worker), do: GenServer.call(worker, :get_state)

  def join(nil, _user), do: Logger.info("No worker available")

  def join(worker, user)
      when is_pid(worker),
      do: GenServer.call(worker, {:join, user})

  def leave(nil, _user), do: Logger.info("No worker available")

  def leave(worker, user)
      when is_pid(worker),
      do: GenServer.call(worker, {:leave, user})

  def remove_member(worker, user)
      when is_pid(worker),
      do: GenServer.call(worker, {:remove_member, user})

  def update(worker, id, payload)
      when is_pid(worker),
      do: GenServer.cast(worker, {:update, id, payload})

  def stop(worker), do: GenServer.cast(worker, :stop)

  def whereis_name(name) do
    case Registry.lookup(RegWorlds, name) do
      [{pid, _ref}] -> pid
      [] -> nil
    end
  end

  @impl GenServer
  def init(record) do
    Logger.info("#{__MODULE__} is starting with args #{inspect(record)}")
    {:ok, %__MODULE__{world_state: record}, {:continue, :setup}}
  end

  @impl GenServer
  def handle_continue(:setup, %__MODULE__{world_state: world_state} = state) do
    WorkerMonitor.monitor(
      self(),
      %{topic: "world", worker_state: world_state}
    )

    {:noreply, state, @timeout}
  end

  @impl GenServer
  def handle_call({:add_member, user}, _from, %__MODULE__{world_state: world_state} = state) do
    {:ok, world_state} = World.add_member(world_state, user)
    new_state = %{state | world_state: world_state}
    {:reply, {:ok, new_state}, new_state, @timeout}
  end

  @impl GenServer
  def handle_call(:get_state, _from, %__MODULE__{world_state: world_state} = state) do
    {:reply, world_state, state, @timeout}
  end

  @impl GenServer
  def handle_call({:join, user}, _from, %__MODULE__{world_state: world_state, grace_timer: grace_timer} = state) do
    case World.join(world_state, user) do
      {:ok, world_state} ->

        # If there is a grace timer present, cancel it!
        if grace_timer, do: Process.cancel_timer(grace_timer)

        new_state = %{state | world_state: world_state, grace_timer: nil}
        {:reply, {:ok, world_state}, new_state, @timeout}

      {:error, reason} ->
        {:reply, {:error, "Join room failure #{reason}"}, state, @timeout}
    end
  end

  @impl GenServer
  def handle_call({:leave, user}, _from, %__MODULE__{world_state: world_state} = state) do
    case World.leave(world_state, user) do
      {:ok, %{presences: presences} = world_state} when presences == [] ->

        # Start a grace timer if presences list drop to zero
        # This timer will emit a timeout if not cancelled
        grace_timer = Process.send_after(self(), :timeout, @grace_period)
        new_state = %{state | world_state: world_state, grace_timer: grace_timer}
        {:reply, {:ok, world_state}, new_state, @timeout}

        # new_state = %{state | world_state: world_state}
        # {:stop, :normal, new_state, new_state}

      {:ok, world_state} ->
        new_state = %{state | world_state: world_state}
        {:reply, {:ok, world_state}, new_state, @timeout}

      {:error, reason} ->
        {:reply, {:error, "Leave room failure #{reason}"}, state, @timeout}
    end
  end

  @impl GenServer
  def handle_call({:remove_member, user}, _from, %__MODULE__{world_state: world_state} = state) do
    {:ok, world_state} = World.remove_member(world_state, user)
    new_state = %{state | world_state: world_state}
    {:reply, {:ok, world_state}, new_state, @timeout}
  end

  @impl GenServer
  def handle_cast({:update, id, payload}, %__MODULE__{world_state: world_state} = state),
    do: {:noreply, %{state | world_state: World.update(world_state, id, payload)}}

  @impl GenServer
  def handle_cast(:stop, state), do: {:stop, :normal, state}

  @impl GenServer
  def handle_info(:timeout, state) do
    Logger.info("#{__MODULE__} timeout")
    {:stop, {:shutdown, :timeout}, state}
  end

  @impl GenServer
  def terminate(reason, _state) do
    Logger.info("#{__MODULE__} stopped : #{inspect(reason)}")
    :ok
  end

  # Private

  defp via(name), do: {:via, Registry, {RegWorlds, name}}
end




# defmodule Api.Worlds.WorldWkr do
#   @moduledoc """
#   The worker module
#   """

#   use GenServer
#   require Logger

#   # time of inactivity before the worker stop
#   @timeout 5 * 60 * 60 * 1_000

#   alias Registry.Worlds, as: RegWorlds
#   alias Api.Worlds.World
#   alias Api.WorkerMonitor

#   def child_spec(args) do
#     %{
#       id: __MODULE__,
#       start: {__MODULE__, :start_link, args},
#       restart: :transient,
#       shutdown: 5000,
#       type: :worker
#     }
#   end

#   def start_link(args) do
#     name = args.id
#     GenServer.start_link(__MODULE__, args, name: via(name))
#   end

#   def add_member(worker, user)
#       when is_pid(worker),
#       do: GenServer.call(worker, {:add_member, user})

#   def get_state(worker), do: GenServer.call(worker, :get_state)

#   def join(nil, _user), do: Logger.info("No worker available")

#   def join(worker, user)
#       when is_pid(worker),
#       do: GenServer.call(worker, {:join, user})

#   def leave(nil, _user), do: Logger.info("No worker available")

#   def leave(worker, user)
#       when is_pid(worker),
#       do: GenServer.call(worker, {:leave, user})

#   def remove_member(worker, user)
#       when is_pid(worker),
#       do: GenServer.call(worker, {:remove_member, user})

#   def update(worker, id, payload)
#       when is_pid(worker),
#       do: GenServer.cast(worker, {:update, id, payload})

#   def stop(worker), do: GenServer.cast(worker, :stop)

#   def whereis_name(name) do
#     case Registry.lookup(RegWorlds, name) do
#       [{pid, _ref}] -> pid
#       [] -> nil
#     end
#   end

#   @impl GenServer
#   def init(record) do
#     Logger.info("#{__MODULE__} is starting with args #{inspect(record)}")
#     {:ok, record, {:continue, :setup}}
#   end

#   @impl GenServer
#   def handle_continue(:setup, state) do
#     WorkerMonitor.monitor(
#       self(),
#       %{topic: "world", worker_state: state}
#     )

#     {:noreply, state, @timeout}
#   end

#   @impl GenServer
#   def handle_call({:add_member, user}, _from, state) do
#     {:ok, state} = World.add_member(state, user)
#     {:reply, {:ok, state}, state, @timeout}
#   end

#   @impl GenServer
#   def handle_call(:get_state, _from, state) do
#     {:reply, state, state, @timeout}
#   end

#   @impl GenServer
#   def handle_call({:join, user}, _from, state) do
#     case World.join(state, user) do
#       {:ok, state} ->
#         {:reply, {:ok, state}, state, @timeout}

#       {:error, reason} ->
#         {:reply, {:error, "Join room failure #{reason}"}, state, @timeout}
#     end
#   end

#   @impl GenServer
#   def handle_call({:leave, user}, _from, state) do
#     case World.leave(state, user) do
#       {:ok, %{presences: presences} = state} when presences == [] ->
#         {:stop, :normal, state, state}

#       {:ok, state} ->
#         {:reply, {:ok, state}, state, @timeout}

#       {:error, reason} ->
#         {:reply, {:error, "Leave room failure #{reason}"}, state, @timeout}
#     end
#   end

#   @impl GenServer
#   def handle_call({:remove_member, user}, _from, state) do
#     {:ok, state} = World.remove_member(state, user)
#     {:reply, {:ok, state}, state, @timeout}
#   end

#   @impl GenServer
#   def handle_cast({:update, id, payload}, state),
#     do: {:noreply, World.update(state, id, payload)}

#   @impl GenServer
#   def handle_cast(:stop, state), do: {:stop, :normal, state}

#   @impl GenServer
#   def handle_info(:timeout, state) do
#     Logger.info("#{__MODULE__} timeout")
#     {:stop, {:shutdown, :timeout}, state}
#   end

#   @impl GenServer
#   def terminate(reason, _state) do
#     Logger.info("#{__MODULE__} stopped : #{inspect(reason)}")
#     :ok
#   end

#   # Private

#   defp via(name), do: {:via, Registry, {RegWorlds, name}}
# end
