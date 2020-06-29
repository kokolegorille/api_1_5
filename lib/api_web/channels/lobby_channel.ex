defmodule ApiWeb.LobbyChannel do
  @moduledoc false

  use ApiWeb, :channel
  require Logger
  @name __MODULE__

  alias ApiWeb.Presence
  alias Api.{Requests, Rooms, Worlds}
  alias ApiWeb.ChannelMonitor

  def join("lobby", _params, socket) do
    send(self(), :after_join)

    ChannelMonitor.monitor_channel(
      self(),
      %{topic: "lobby", user: socket.assigns.user}
    )

    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    {:ok, _} =
      Presence.track(socket, socket.assigns.user.id, %{
        name: socket.assigns.user.name,
        online_at: :os.system_time(:millisecond)
      })

    push(socket, "presence_state", Presence.list(socket))
    push(socket, "list_requests", %{requests: Requests.list_requests()})
    push(socket, "list_rooms", %{rooms: Rooms.list_rooms()})
    push(socket, "list_worlds", %{worlds: Worlds.list_worlds()})

    {:noreply, socket}
  end

  def handle_in(
        "create_request",
        %{"name" => name, "description" => description} = _params,
        socket
      ) do
    request = Requests.new(name, description, socket.assigns.user)

    case Requests.add_request(request) do
      {:ok, request} ->
        broadcast!(socket, "request_created", %{request: request})

      {:error, reason} ->
        push(socket, "request_created_error", %{error: reason})
    end

    {:noreply, socket}
  end

  def handle_in("cancel_request", id, socket) do
    case Requests.delete_by_owner_and_id(socket.assigns.user, id) do
      {:ok, _keys} ->
        broadcast!(socket, "request_cancelled", %{id: id})

      {:error, reason} ->
        log("cancel request error #{reason}")
    end

    {:noreply, socket}
  end

  def handle_in("accept_request", id, socket) do
    case Requests.get_by_id(id) do
      [] ->
        log("accept request error : #{id} not found")

      [request | _tail] ->
        # CREATE A NEW ROOM
        # NOTIFY MEMBERS BY MESSAGE ON THERE PRIVATE TOPIC

        user = socket.assigns.user
        %{owner: owner, name: name, description: description} = request

        # Create initial room structure for worker
        room =
          Rooms.new(%{
            id: UUID.uuid4(),
            name: name,
            description: description,
            owner: owner,
            members: [owner, user],
            inserted_at: DateTime.utc_now()
          })

        {:ok, _pid} = Rooms.start_worker(room)

        notify_user(socket, owner, "join_room", %{room_id: room.id})
        notify_user(socket, user, "join_room", %{room_id: room.id})

        case Requests.delete_by_id(id) do
          {:ok, _keys} ->
            broadcast!(socket, "request_accepted", %{id: id})

          {:error, reason} ->
            log("accept request error #{reason}")
        end

        broadcast!(socket, "room_created", %{room: room})
    end

    {:noreply, socket}
  end

  def handle_in(
        "create_world",
        %{"name" => name, "description" => description, "access" => access} = _params,
        socket
      ) do
    user = socket.assigns.user

    world =
      Worlds.new(%{
        id: UUID.uuid4(),
        name: name,
        description: description,
        owner: user,
        members: [user],
        access: access,
        inserted_at: DateTime.utc_now()
      })

    {:ok, _pid} = Worlds.start_worker(world)

    broadcast!(socket, "world_created", %{world: world})

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

  defp notify_user(socket, user, command, payload) do
    socket.endpoint.broadcast!("user:#{user.id}", command, payload)
  end

  defp log(message), do: Logger.debug(fn -> message end)
end
