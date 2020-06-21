defmodule ApiWeb.RoomChannel do
  @moduledoc false

  use ApiWeb, :channel
  require Logger
  @name __MODULE__

  alias ApiWeb.Presence
  alias ApiWeb.ChannelMonitor
  alias Api.Rooms

  def join("room:" <> id, _params, socket) do
    user = socket.assigns.user

    with worker when is_pid(worker) <- Rooms.whereis_name(id),
         {:ok, _} <- Rooms.join(worker, user) do
      socket = assign(socket, :room_id, id)

      ChannelMonitor.monitor_channel(
        self(),
        %{topic: "room", room_id: id, user: user}
      )

      # Pass the room state to after join while the worker is loaded!
      send(self(), {:after_join, Rooms.get_state(worker)})
      {:ok, socket}
    else
      {:error, _} ->
        {:error, %{reason: "Not authorized"}}

      nil ->
        {:error, %{reason: "Worker not available"}}
    end
  end

  def handle_info({:after_join, room_state}, socket) do
    room_id = socket.assigns.room_id
    log("You have entered #{@name} with id #{room_id}")

    {:ok, _} =
      Presence.track(socket, socket.assigns.user.id, %{
        name: socket.assigns.user.name,
        online_at: :os.system_time(:millisecond)
      })

    push(socket, "presence_state", Presence.list(socket))

    broadcast!(
      socket, "room_updated", %{room_state: room_state}
    )

    {:noreply, socket}
  end

  def terminate(reason, _socket) do
    log("#{@name} > leave #{inspect(reason)}")
    :ok
  end

  # PRIVATE

  defp log(message), do: Logger.debug(fn -> message end)
end
