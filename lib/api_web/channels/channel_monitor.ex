defmodule ApiWeb.ChannelMonitor do
  @moduledoc """
  The channel monitor detect when a room channel goes down.
  It uses notifier to propagate messages.
  """

  use GenServer
  require Logger
  @name __MODULE__

  alias ApiWeb.Notifier
  alias Api.{Requests, Rooms}

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

    %{topic: topic, user: user} = channel_info

    case topic do
      "lobby" ->
        case Requests.delete_by_owner(user) do
          {:ok, keys} ->
            notify(%{type: :requests_deleted, payload: keys})
          {:error, _reason} ->
            nil
        end

      "room" ->
        # There is no need to notify when a user leave a room channel
        channel_info.room_id
          |> Rooms.whereis_name()
          |> Rooms.leave(user)

      _ ->
        Logger.debug(fn ->
          "Unknown topic #{topic} #{inspect(channel_info)} #{inspect(status)}"
        end)
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
