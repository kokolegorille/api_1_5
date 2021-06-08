defmodule ApiWeb.UserChannel do
  @moduledoc false

  use ApiWeb, :channel
  require Logger
  @name __MODULE__

  def join("user:" <> id, _params, socket) do
    if id === socket.assigns.user.id do
      {:ok, socket}
    else
      {:error, %{reason: "Not authorized"}}
    end
  end

  def handle_in("ping", %{"target" => target}, socket) do
    notify_user_by_id(
      socket,
      target,
      "ping_received",
      %{
        from: socket.assigns.user,
        at: :os.system_time(:millisecond)
      }
    )

    {:noreply, socket}
  end

  def handle_in(command, payload, socket) do
    message =
      "#{__MODULE__} > Unknown command '#{command}' " <>
        "(#{inspect(command, base: :hex)}) " <>
        "with payload #{inspect(payload)}"

    Logger.debug(fn -> message end)
    {:noreply, socket}
  end

  def terminate(reason, _socket) do
    log("#{@name} > leave #{inspect(reason)}")
    :ok
  end

  # PRIVATE

  defp notify_user_by_id(socket, user_id, command, payload) do
    socket.endpoint.broadcast!("user:#{user_id}", command, payload)
  end

  defp log(message), do: Logger.debug(fn -> message end)
end
