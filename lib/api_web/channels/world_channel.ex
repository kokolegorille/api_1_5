defmodule ApiWeb.WorldChannel do
  @moduledoc false

  use ApiWeb, :channel
  require Logger
  @name __MODULE__

  alias ApiWeb.Presence
  alias ApiWeb.ChannelMonitor
  alias Api.Babylon

  def join("world:" <> id, _params, socket) do
    user = socket.assigns.user

    with worker when is_pid(worker) <- Babylon.whereis_name(id),
         {:ok, _} <- Babylon.join(worker, user) do
      socket = assign(socket, :world_id, id)

      ChannelMonitor.monitor_channel(
        self(),
        %{topic: "world", id: id, user: user}
      )

      # Pass the room state to after join while the worker is loaded!
      send(self(), {:after_join, Babylon.get_state(worker)})
      {:ok, socket}
    else
      {:error, _} ->
        {:error, %{reason: "Not authorized"}}

      nil ->
        {:error, %{reason: "Worker not available"}}
    end
  end

  def handle_info({:after_join, world_state}, socket) do
    world_id = socket.assigns.world_id
    log("You have entered #{@name} with id #{world_id}")

    {:ok, _} =
      Presence.track(socket, socket.assigns.user.id, %{
        name: socket.assigns.user.name,
        online_at: :os.system_time(:millisecond)
      })

    push(socket, "presence_state", Presence.list(socket))

    broadcast!(
      socket,
      "world_updated",
      %{world_state: world_state}
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
