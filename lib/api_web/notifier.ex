defmodule ApiWeb.Notifier do
  @moduledoc """
  The notifier, used by channel monitor.
  """

  require Logger

  alias ApiWeb.Endpoint

  def notify(%{type: :requests_deleted, payload: keys}) do
    Enum.each(keys, fn id ->
      Endpoint.broadcast!("lobby", "request_cancelled", %{id: id})
    end)
  end

  def notify(%{type: :room_left, payload: %{room_state: room_state}}) do
    Endpoint.broadcast!("lobby", "room_cancelled", %{id: room_state.id})
  end

  # Sample message
  # NOTIFY MESSAGE: %{payload: %{room_id: 1, user: user}, type: :down}
  def notify(message) do
    Logger.debug(fn -> "NOTIFY MESSAGE #{inspect(message)}" end)
  end
end
