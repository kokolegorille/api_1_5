defmodule Api.WorkerMonitor do
  @moduledoc """
  The room monitor detect when a room worker goes down.
  It uses notifier to propagate messages.
  """

  use GenServer
  require Logger
  @name __MODULE__

  alias ApiWeb.Notifier

  def start_link(_args), do: GenServer.start_link(__MODULE__, %{}, name: @name)

  def monitor(pid, worker_state), do: GenServer.cast(@name, {:monitor, pid, worker_state})

  @impl GenServer
  def init(args) do
    Process.flag(:trap_exit, true)
    {:ok, args}
  end

  @impl GenServer
  def handle_cast({:monitor, pid, worker_state}, state) do
    Logger.debug(fn -> "Receive info : #{inspect(worker_state)}" end)
    Process.monitor(pid)
    state = Map.put(state, pid, worker_state)
    {:noreply, state}
  end

  @impl GenServer
  def handle_info({:DOWN, _ref, :process, pid, status}, state) do
    %{topic: topic, worker_state: worker_state} = Map.get(state, pid)
    Logger.debug(fn -> "DOWN catched! #{inspect(worker_state)} #{inspect(status)}" end)

    case topic do
      "room" ->
        notify(%{type: :room_left, payload: worker_state})

      "world" ->
        notify(%{type: :world_left, payload: worker_state})
    end

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
