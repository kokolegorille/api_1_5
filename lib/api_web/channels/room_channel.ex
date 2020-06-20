defmodule ApiWeb.RoomChannel do
  @moduledoc false

  use ApiWeb, :channel
  require Logger
  @name __MODULE__

  alias ApiWeb.Presence
  alias ApiWeb.ChannelMonitor
  alias Api.Rooms

  def join("room:" <> id, _params, socket) do
    case Rooms.whereis_name(id) do
      worker when is_pid(worker) ->
        socket = assign(socket, :room_id, id)
        user = socket.assigns.user

        ChannelMonitor.monitor_channel(
          self(),
          %{topic: "room", room_id: id, user: user}
        )

        Rooms.join(worker, user)

        send(self(), :after_join)
        {:ok, socket}
      nil ->
        {:error, %{reason: "Worker not available"}}
    end
  end


  def handle_info(:after_join, socket) do
    room_id = socket.assigns.room_id
    log("You have entered #{@name} with id #{room_id}")

    {:ok, _} =
      Presence.track(socket, socket.assigns.user.id, %{
        name: socket.assigns.user.name,
        online_at: :os.system_time(:millisecond)
      })

    push(socket, "presence_state", Presence.list(socket))

    {:noreply, socket}
  end

  def terminate(reason, _socket) do
    log("#{@name} > leave #{inspect(reason)}")
    :ok
  end

  # PRIVATE

  defp log(message), do: Logger.debug(fn -> message end)
end
