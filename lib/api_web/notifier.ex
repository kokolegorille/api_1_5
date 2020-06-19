defmodule ApiWeb.Notifier do
  @moduledoc """
  The notifier, used by channel monitor.
  """

  require Logger

  alias ApiWeb.Endpoint

  # def notify(%{payload: %{topic: "lobby", user: user}, type: :down}) do
  #   Endpoint.boradcast!("lobby")
  # end

  def notify(%{payload: %{topic: "lobby", ids: ids}, type: :down}) do
    Enum.each(ids, fn id ->
      Endpoint.broadcast!("lobby", "request_cancelled", %{id: id})
    end)
  end

  # Sample message
  # NOTIFY MESSAGE: %{payload: %{room_id: 1, user: user}, type: :down}
  def notify(message) do
    Logger.debug(fn -> "NOTIFY MESSAGE #{inspect(message)}" end)
  end
end
