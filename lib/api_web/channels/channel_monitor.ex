defmodule ApiWeb.ChannelMonitor do
  @moduledoc """
  The channel monitor detect when a room channel goes down.
  It uses notifier to propagate messages.
  """

  use GenServer
  alias ApiWeb.Notifier
  require Logger
  @name __MODULE__

  def start_link(_args), do: GenServer.start_link(__MODULE__, %{}, name: @name)

  def monitor_channel(pid, channel_info), do: GenServer.cast(@name, {:monitor, pid, channel_info})

  @impl GenServer
  def init(args) do
    Process.flag(:trap_exit, true)
    {:ok, args}
  end

  @impl GenServer
  def handle_cast({:monitor, pid, channel_info}, state) do
    Logger.debug(fn -> "Receive channel info : #{inspect(channel_info)}" end)
    Process.monitor(pid)
    state = Map.put(state, pid, channel_info)
    {:noreply, state}
  end

  @impl GenServer
  def handle_info({:DOWN, _ref, :process, pid, status}, state) do
    channel_info = Map.get(state, pid)
    Logger.debug(fn -> "DOWN catched! #{inspect(channel_info)} #{inspect(status)}" end)

    notify(%{type: :down, payload: channel_info})
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
