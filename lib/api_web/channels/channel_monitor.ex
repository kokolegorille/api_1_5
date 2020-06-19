defmodule ApiWeb.ChannelMonitor do
  @moduledoc """
  The channel monitor detect when a room channel goes down.
  It uses notifier to propagate messages.
  """

  use GenServer
  require Logger
  @name __MODULE__

  alias ApiWeb.Notifier
  alias Api.Requests

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

    case clean_up(channel_info) do
      {:ok, []} ->
        nil

      {:ok, ids} ->
        notify(%{type: :down, payload: Map.put(channel_info, :ids, ids)})

      _ ->
        nil
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

  defp clean_up(%{topic: "lobby", user: user}) do
    Requests.delete_by_owner(user)
  end

  defp clean_up(%{topic: "room", room_id: _room_id, user_id: _user_id}) do
  end

  defp clean_up(channel_info) do
    Logger.debug(fn -> "#{__MODULE__} channel info error : #{inspect(channel_info)}" end)
  end
end
