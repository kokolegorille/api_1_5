defmodule ApiWeb.Notifier do
  @moduledoc """
  The notifier, used by channel monitor.
  """

  require Logger

  # Sample message
  # NOTIFY MESSAGE: %{payload: %{room_id: 1, user_id: 1}, type: :down}
  def notify(message) do
    Logger.debug fn -> "NOTIFY MESSAGE #{inspect message}" end
  end
end
