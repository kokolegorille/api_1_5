defmodule ApiWeb.LobbyChannel do
  @moduledoc false

  use ApiWeb, :channel
  require Logger
  @name __MODULE__
  alias ApiWeb.Presence

  def join("lobby", _params, socket) do
    send(self(), :after_join)
    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    push(socket, "presence_state", Presence.list(socket))
    {:ok, _} = Presence.track(socket, socket.assigns.user.id, %{
      name: socket.assigns.user.name,
      online_at: :os.system_time(:millisecond)
    })
    {:noreply, socket}
  end

  def terminate(reason, _socket) do
    log("#{@name} > leave #{inspect(reason)}")
    :ok
  end

  # PRIVATE

  defp log(message), do: Logger.debug(fn -> message end)
end
