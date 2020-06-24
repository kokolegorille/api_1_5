defmodule ApiWeb.Notifier do
  @moduledoc """
  The notifier, used by channel monitor.
  """

  require Logger

  alias ApiWeb.Endpoint

  # A room worker event has been catched by worker monitor
  def notify(%{type: :room_left, payload: room_state}) do
    Endpoint.broadcast!("lobby", "room_cancelled", %{id: room_state.id})
    Endpoint.broadcast!("room:#{room_state.id}", "room_cancelled", %{})
  end

  # A world worker event has been catched by worker monitor
  def notify(%{type: :world_left, payload: world_state}) do
    Endpoint.broadcast!("lobby", "world_cancelled", %{id: world_state.id})
    Endpoint.broadcast!("world:#{world_state.id}", "world_cancelled", %{})
  end

  # A user left event has been catched by channel monitor on lobby channel
  def notify(%{type: :requests_deleted, payload: keys}) do
    Enum.each(keys, fn id ->
      Endpoint.broadcast!("lobby", "request_cancelled", %{id: id})
    end)
  end

  # A user left event has been catched by channel monitor on room channel
  def notify(%{type: :user_left_room, payload: room_state}) do
    Endpoint.broadcast!("room:#{room_state.id}", "room_updated", %{room_state: room_state})
  end

  # A user left event has been catched by channel monitor on world channel
  def notify(%{type: :user_left_world, payload: world_state}) do
    Endpoint.broadcast!("world:#{world_state.id}", "world_updated", %{world_state: world_state})
  end

  # Sample message
  # NOTIFY MESSAGE: %{payload: %{room_id: 1, user: user}, type: :down}
  def notify(message) do
    Logger.debug(fn -> "NOTIFY MESSAGE #{inspect(message)}" end)
  end
end
