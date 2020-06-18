defmodule ApiWeb.RoomChannel do
  @moduledoc false

  use ApiWeb, :channel
  require Logger
  @name __MODULE__

  alias ApiWeb.ChannelMonitor

  def join("room:" <> id, _params, socket) do
    room_id = String.to_integer(id)
    socket = assign(socket, :room_id, room_id)

    ChannelMonitor.monitor_channel(
      self(),
      %{room_id: room_id, user_id: socket.assigns.user.id}
    )

    send(self(), :after_join)
    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    room_id = socket.assigns.room_id
    log("You have entered #{@name} with id #{room_id}")

    {:noreply, socket}
  end

  def terminate(reason, _socket) do
    log("#{@name} > leave #{inspect(reason)}")
    :ok
  end

  # PRIVATE

  defp log(message), do: Logger.debug(fn -> message end)
end
