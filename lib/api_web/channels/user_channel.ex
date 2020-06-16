defmodule ApiWeb.UserChannel do
  @moduledoc false

  use ApiWeb, :channel
  require Logger
  @name __MODULE__

  def join("user:" <> id, _params, socket) do
    if String.to_integer(id) === socket.assigns.user.id do
      {:ok, socket}
    else
      {:error, %{reason: "Not authorized"}}
    end
  end

  def terminate(reason, _socket) do
    log("#{@name} > leave #{inspect(reason)}")
    :ok
  end

  # PRIVATE

  defp log(message), do: Logger.debug(fn -> message end)
end
