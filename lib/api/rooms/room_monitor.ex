defmodule Api.Rooms.RoomMonitor do
  @moduledoc """
  The room monitor detect when a room worker goes down.
  It uses notifier to propagate messages.
  """

  use GenServer
  require Logger
  @name __MODULE__

  alias ApiWeb.Notifier

  def start_link(_args), do: GenServer.start_link(__MODULE__, %{}, name: @name)

  def monitor_room(pid, room_state), do: GenServer.cast(@name, {:monitor, pid, room_state})

  @impl GenServer
  def init(args) do
    Process.flag(:trap_exit, true)
    {:ok, args}
  end

  @impl GenServer
  def handle_cast({:monitor, pid, room_state}, state) do
    Logger.debug(fn -> "Receive room info : #{inspect(room_state)}" end)
    Process.monitor(pid)
    state = Map.put(state, pid, room_state)
    {:noreply, state}
  end

  @impl GenServer
  def handle_info({:DOWN, _ref, :process, pid, status}, state) do
    room_state = Map.get(state, pid)
    Logger.debug(fn -> "DOWN catched! #{inspect(room_state)} #{inspect(status)}" end)

    notify(%{type: :room_left, payload: room_state})

    state = Map.delete(state, pid)
    {:noreply, state}
  end

  @impl GenServer
  def terminate(reason, _state) do
    Logger.debug(fn -> "#{__MODULE__} stopped : #{inspect(reason)}" end)
    :ok
  end

  defp notify(message) do
    Notifier.notify(message)
  end
end
